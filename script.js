// Dashboard JavaScript
let chartInstances = {}; // Store chart instances for cleanup

document.addEventListener('DOMContentLoaded', function() {
    initializeDashboard();
    setupEventListeners();
});

function initializeDashboard() {
    updateLastUpdateTime();
    createSparklines();
    createMainCharts();
    animateKPICards();
}

function updateLastUpdateTime() {
    const now = new Date();
    const timeString = now.toLocaleString('pt-BR', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    });
    document.getElementById('last-update').textContent = timeString;
}

function createSparklines() {
    const sparklineConfigs = [
        { id: 'conversion-sparkline', data: mockData.kpis.conversion_rate.sparkline, color: '#3498db' },
        { id: 'cac-sparkline', data: mockData.kpis.cac.sparkline, color: '#e74c3c' },
        { id: 'mrr-sparkline', data: mockData.kpis.mrr.sparkline, color: '#2ecc71' },
        { id: 'sla-sparkline', data: mockData.kpis.sla_whatsapp.sparkline, color: '#f39c12' },
        { id: 'leadtime-sparkline', data: mockData.kpis.lead_time.sparkline, color: '#9b59b6' },
        { id: 'margin-sparkline', data: mockData.kpis.gross_margin.sparkline, color: '#1abc9c' },
        { id: 'roi-sparkline', data: mockData.kpis.events_roi.sparkline, color: '#34495e' }
    ];

    sparklineConfigs.forEach(config => {
        createSparkline(config.id, config.data, config.color);
    });
}

function createSparkline(canvasId, data, color) {
    const ctx = document.getElementById(canvasId);
    if (!ctx) return;
    
    // Destroy existing chart if it exists
    if (chartInstances[canvasId]) {
        chartInstances[canvasId].destroy();
    }
    
    chartInstances[canvasId] = new Chart(ctx.getContext('2d'), {
        type: 'line',
        data: {
            labels: data.map((_, i) => i),
            datasets: [{
                data: data,
                borderColor: color,
                backgroundColor: color + '20',
                borderWidth: 2,
                fill: true,
                tension: 0.4,
                pointRadius: 0,
                pointHoverRadius: 4
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { display: false }
            },
            scales: {
                x: { display: false },
                y: { display: false }
            },
            elements: {
                point: { radius: 0 }
            },
            interaction: {
                intersect: false
            }
        }
    });
}

function createMainCharts() {
    createSalesFunnelChart();
    createLeadSourceChart();
    createMRREvolutionChart();
    createResponseTimeChart();
}

function createSalesFunnelChart() {
    const ctx = document.getElementById('sales-funnel');
    if (!ctx) return;
    
    // Destroy existing chart if it exists
    if (chartInstances['sales-funnel']) {
        chartInstances['sales-funnel'].destroy();
    }
    
    chartInstances['sales-funnel'] = new Chart(ctx.getContext('2d'), {
        type: 'bar',
        data: {
            labels: mockData.salesFunnel.labels,
            datasets: [{
                label: 'Quantidade',
                data: mockData.salesFunnel.values,
                backgroundColor: mockData.salesFunnel.colors,
                borderRadius: 6,
                borderSkipped: false
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { display: false },
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            const value = context.parsed.y;
                            const total = mockData.salesFunnel.values[0];
                            const percentage = ((value / total) * 100).toFixed(1);
                            return `${context.label}: ${value} (${percentage}%)`;
                        }
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: {
                        callback: function(value) {
                            return value.toLocaleString('pt-BR');
                        }
                    }
                }
            }
        }
    });
}

function createLeadSourceChart() {
    const ctx = document.getElementById('leads-source');
    if (!ctx) return;
    
    // Destroy existing chart if it exists
    if (chartInstances['leads-source']) {
        chartInstances['leads-source'].destroy();
    }
    
    chartInstances['leads-source'] = new Chart(ctx.getContext('2d'), {
        type: 'doughnut',
        data: {
            labels: mockData.leadSources.labels,
            datasets: [{
                data: mockData.leadSources.values,
                backgroundColor: mockData.leadSources.colors,
                borderWidth: 0
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    position: 'right',
                    labels: {
                        usePointStyle: true,
                        padding: 20
                    }
                },
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            const value = context.parsed;
                            return `${context.label}: ${value}%`;
                        }
                    }
                }
            }
        }
    });
}

function createMRREvolutionChart() {
    const ctx = document.getElementById('mrr-evolution');
    if (!ctx) return;
    
    // Destroy existing chart if it exists
    if (chartInstances['mrr-evolution']) {
        chartInstances['mrr-evolution'].destroy();
    }
    
    chartInstances['mrr-evolution'] = new Chart(ctx.getContext('2d'), {
        type: 'line',
        data: {
            labels: mockData.mrrEvolution.labels,
            datasets: [
                {
                    label: 'MRR Real',
                    data: mockData.mrrEvolution.values,
                    borderColor: '#2ecc71',
                    backgroundColor: '#2ecc71' + '20',
                    borderWidth: 3,
                    fill: true,
                    tension: 0.4
                },
                {
                    label: 'Meta',
                    data: mockData.mrrEvolution.targets,
                    borderColor: '#95a5a6',
                    backgroundColor: 'transparent',
                    borderWidth: 2,
                    borderDash: [5, 5],
                    fill: false,
                    tension: 0.4
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: true,
                    position: 'top'
                },
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            const value = context.parsed.y;
                            return `${context.dataset.label}: R$ ${value.toLocaleString('pt-BR')}`;
                        }
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: false,
                    ticks: {
                        callback: function(value) {
                            return 'R$ ' + (value / 1000).toFixed(0) + 'K';
                        }
                    }
                }
            }
        }
    });
}

function createResponseTimeChart() {
    const ctx = document.getElementById('response-time');
    if (!ctx) return;
    
    // Destroy existing chart if it exists
    if (chartInstances['response-time']) {
        chartInstances['response-time'].destroy();
    }
    
    chartInstances['response-time'] = new Chart(ctx.getContext('2d'), {
        type: 'bar',
        data: {
            labels: mockData.responseTime.labels,
            datasets: [
                {
                    label: 'Tempo Médio (min)',
                    data: mockData.responseTime.avgTime,
                    backgroundColor: mockData.responseTime.avgTime.map(time => 
                        time <= mockData.responseTime.slaTarget ? '#2ecc71' : '#e74c3c'
                    ),
                    borderRadius: 4,
                    yAxisID: 'y'
                },
                {
                    label: 'SLA (15 min)',
                    data: new Array(7).fill(mockData.responseTime.slaTarget),
                    type: 'line',
                    borderColor: '#f39c12',
                    backgroundColor: 'transparent',
                    borderWidth: 2,
                    borderDash: [5, 5],
                    pointRadius: 0,
                    yAxisID: 'y'
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: true,
                    position: 'top'
                },
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            if (context.dataset.label === 'SLA (15 min)') {
                                return `SLA: ${context.parsed.y} min`;
                            }
                            return `${context.dataset.label}: ${context.parsed.y} min`;
                        }
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    title: {
                        display: true,
                        text: 'Tempo (minutos)'
                    }
                }
            }
        }
    });
}

function animateKPICards() {
    const cards = document.querySelectorAll('.kpi-card');
    cards.forEach((card, index) => {
        setTimeout(() => {
            card.style.opacity = '0';
            card.style.transform = 'translateY(20px)';
            card.style.transition = 'all 0.6s ease-out';
            
            setTimeout(() => {
                card.style.opacity = '1';
                card.style.transform = 'translateY(0)';
            }, 100);
        }, index * 100);
    });
}

function setupEventListeners() {
    // Filter event listeners
    document.getElementById('period-filter').addEventListener('change', handlePeriodChange);
    document.getElementById('channel-filter').addEventListener('change', handleChannelChange);
    document.getElementById('segment-filter').addEventListener('change', handleSegmentChange);
    
    // Auto-refresh every 5 minutes
    setInterval(updateLastUpdateTime, 5 * 60 * 1000);
    
    // Simulate real-time updates
    setInterval(simulateDataUpdate, 30000);
}

function handlePeriodChange(event) {
    const period = event.target.value;
    console.log(`Período alterado para: ${period}`);
    
    // Simulate loading
    showLoading();
    
    setTimeout(() => {
        updateChartsForPeriod(period);
        hideLoading();
    }, 1000);
}

function handleChannelChange(event) {
    const channel = event.target.value;
    console.log(`Canal alterado para: ${channel}`);
    
    // Simulate loading
    showLoading();
    
    setTimeout(() => {
        updateDataForChannel(channel);
        hideLoading();
    }, 800);
}

function handleSegmentChange(event) {
    const segment = event.target.value;
    console.log(`Segmento alterado para: ${segment}`);
    
    // Simulate loading
    showLoading();
    
    setTimeout(() => {
        updateDataForSegment(segment);
        hideLoading();
    }, 800);
}

function updateChartsForPeriod(period) {
    // Simulate different data for different periods
    const periodMultipliers = {
        '7d': 0.7,
        '30d': 1.0,
        '90d': 1.3,
        '12m': 1.8
    };
    
    const multiplier = periodMultipliers[period] || 1.0;
    
    // Update chart descriptions
    document.querySelectorAll('.chart-period').forEach(element => {
        const periodText = {
            '7d': 'Últimos 7 dias',
            '30d': 'Últimos 30 dias',
            '90d': 'Últimos 90 dias',
            '12m': 'Últimos 12 meses'
        };
        element.textContent = periodText[period] || 'Últimos 30 dias';
    });
    
    // Update KPIs values based on period
    updateKPIsForPeriod(period, multiplier);
    
    // Recreate charts with new data
    createMainCharts();
    createSparklines();
}

function updateDataForChannel(channel) {
    if (channel === 'all') {
        // Reset to original data
        updateKPIsForPeriod('30d', 1.0);
        createMainCharts();
        createSparklines();
        return;
    }
    
    const channelData = mockData.channelPerformance[channel];
    if (channelData) {
        console.log(`Dados do canal ${channel}:`, channelData);
        
        // Update KPIs based on channel performance
        updateKPIsForChannel(channel, channelData);
        
        // Update charts
        createMainCharts();
        createSparklines();
    }
}

function updateDataForSegment(segment) {
    console.log(`Atualizando dados para segmento: ${segment}`);
    
    if (segment === 'all') {
        // Reset to original data
        updateKPIsForPeriod('30d', 1.0);
        createMainCharts();
        createSparklines();
        return;
    }
    
    // Simulate different data for different segments
    const segmentMultipliers = {
        'enterprise': 1.5,
        'mid-market': 1.2,
        'smb': 0.8
    };
    
    const multiplier = segmentMultipliers[segment] || 1.0;
    updateKPIsForSegment(segment, multiplier);
    
    // Update charts
    createMainCharts();
    createSparklines();
}

function simulateDataUpdate() {
    // Simulate small random changes in KPIs
    const kpiCards = document.querySelectorAll('.kpi-card .value');
    
    kpiCards.forEach(card => {
        const currentValue = parseFloat(card.textContent.replace(/[^0-9.]/g, ''));
        if (!isNaN(currentValue)) {
            const variation = (Math.random() - 0.5) * 0.02; // ±1% variation
            const newValue = currentValue * (1 + variation);
            
            // Add pulse animation
            card.style.transition = 'all 0.3s ease';
            card.style.transform = 'scale(1.05)';
            
            setTimeout(() => {
                card.style.transform = 'scale(1)';
            }, 300);
        }
    });
}

function showLoading() {
    // Add loading state to dashboard
    const existingLoading = document.getElementById('loading-overlay');
    if (existingLoading) return;
    
    const loadingDiv = document.createElement('div');
    loadingDiv.id = 'loading-overlay';
    loadingDiv.innerHTML = `
        <div style="position: fixed; top: 0; left: 0; width: 100%; height: 100%; 
                    background: rgba(0,0,0,0.5); display: flex; align-items: center; 
                    justify-content: center; z-index: 9999;">
            <div style="background: white; padding: 20px; border-radius: 10px; 
                        display: flex; align-items: center; gap: 15px;">
                <div class="loading"></div>
                <span>Atualizando dashboard...</span>
            </div>
        </div>
    `;
    document.body.appendChild(loadingDiv);
}

function hideLoading() {
    const loadingDiv = document.getElementById('loading-overlay');
    if (loadingDiv) {
        loadingDiv.remove();
    }
}

// Functions to update KPIs based on filters
function updateKPIsForPeriod(period, multiplier) {
    const kpiValues = {
        'conversion-rate': Math.max(5, Math.min(25, mockData.kpis.conversion_rate.current * multiplier)),
        'cac': Math.max(300, mockData.kpis.cac.current * (2 - multiplier)),
        'mrr': Math.max(100000, mockData.kpis.mrr.current * multiplier),
        'sla': Math.max(80, Math.min(98, mockData.kpis.sla_whatsapp.current * multiplier)),
        'leadtime': Math.max(2, mockData.kpis.lead_time.current * (2 - multiplier)),
        'margin': Math.max(40, Math.min(85, mockData.kpis.gross_margin.current * multiplier)),
        'roi': Math.max(100, mockData.kpis.events_roi.current * multiplier)
    };
    
    updateKPIDisplayValues(kpiValues);
}

function updateKPIsForChannel(channel, channelData) {
    const conversionRate = Math.max(5, Math.min(25, (channelData.conversions / channelData.leads * 100)));
    const cac = Math.max(300, channelData.cost / channelData.conversions);
    
    const kpiValues = {
        'conversion-rate': conversionRate,
        'cac': cac,
        'mrr': Math.max(100000, mockData.kpis.mrr.current * (channelData.roi / 200)),
        'sla': mockData.kpis.sla_whatsapp.current,
        'leadtime': mockData.kpis.lead_time.current,
        'margin': mockData.kpis.gross_margin.current,
        'roi': channelData.roi
    };
    
    updateKPIDisplayValues(kpiValues);
}

function updateKPIsForSegment(segment, multiplier) {
    const kpiValues = {
        'conversion-rate': Math.max(5, Math.min(25, mockData.kpis.conversion_rate.current * multiplier)),
        'cac': Math.max(300, mockData.kpis.cac.current * (2 - multiplier)),
        'mrr': Math.max(100000, mockData.kpis.mrr.current * multiplier),
        'sla': Math.max(80, Math.min(98, mockData.kpis.sla_whatsapp.current * multiplier)),
        'leadtime': Math.max(2, mockData.kpis.lead_time.current * (2 - multiplier)),
        'margin': Math.max(40, Math.min(85, mockData.kpis.gross_margin.current * multiplier)),
        'roi': Math.max(100, mockData.kpis.events_roi.current * multiplier)
    };
    
    updateKPIDisplayValues(kpiValues);
}

function updateKPIDisplayValues(kpiValues) {
    // Update conversion rate
    const conversionCard = Array.from(document.querySelectorAll('.kpi-title')).find(el => el.textContent.includes('Taxa de Conversão'));
    if (conversionCard) {
        const valueElement = conversionCard.closest('.kpi-card').querySelector('.value');
        if (valueElement) {
            valueElement.textContent = kpiValues['conversion-rate'].toFixed(1) + '%';
            updateCardStatus(conversionCard.closest('.kpi-card'), kpiValues['conversion-rate'], 15);
        }
    }
    
    // Update CAC
    const cacCard = Array.from(document.querySelectorAll('.kpi-title')).find(el => el.textContent.includes('CAC'));
    if (cacCard) {
        const valueElement = cacCard.closest('.kpi-card').querySelector('.value');
        if (valueElement) {
            valueElement.textContent = 'R$ ' + Math.round(kpiValues['cac']).toLocaleString('pt-BR');
            updateCardStatus(cacCard.closest('.kpi-card'), kpiValues['cac'], 500, true);
        }
    }
    
    // Update MRR
    const mrrCard = Array.from(document.querySelectorAll('.kpi-title')).find(el => el.textContent.includes('MRR'));
    if (mrrCard) {
        const valueElement = mrrCard.closest('.kpi-card').querySelector('.value');
        if (valueElement) {
            valueElement.textContent = 'R$ ' + Math.round(kpiValues['mrr'] / 1000).toLocaleString('pt-BR') + 'K';
            updateCardStatus(mrrCard.closest('.kpi-card'), kpiValues['mrr'], 250000);
        }
    }
    
    // Update SLA
    const slaCard = Array.from(document.querySelectorAll('.kpi-title')).find(el => el.textContent.includes('SLA WhatsApp'));
    if (slaCard) {
        const valueElement = slaCard.closest('.kpi-card').querySelector('.value');
        if (valueElement) {
            valueElement.textContent = Math.round(kpiValues['sla']) + '%';
            updateCardStatus(slaCard.closest('.kpi-card'), kpiValues['sla'], 90);
        }
    }
    
    // Update Lead Time
    const leadTimeCard = Array.from(document.querySelectorAll('.kpi-title')).find(el => el.textContent.includes('Lead Time'));
    if (leadTimeCard) {
        const valueElement = leadTimeCard.closest('.kpi-card').querySelector('.value');
        if (valueElement) {
            valueElement.textContent = kpiValues['leadtime'].toFixed(1) + ' dias';
            updateCardStatus(leadTimeCard.closest('.kpi-card'), kpiValues['leadtime'], 5, true);
        }
    }
    
    // Update Margin
    const marginCard = Array.from(document.querySelectorAll('.kpi-title')).find(el => el.textContent.includes('Margem Bruta'));
    if (marginCard) {
        const valueElement = marginCard.closest('.kpi-card').querySelector('.value');
        if (valueElement) {
            valueElement.textContent = Math.round(kpiValues['margin']) + '%';
            updateCardStatus(marginCard.closest('.kpi-card'), kpiValues['margin'], 60);
        }
    }
    
    // Update ROI
    const roiCard = Array.from(document.querySelectorAll('.kpi-title')).find(el => el.textContent.includes('ROI Eventos'));
    if (roiCard) {
        const valueElement = roiCard.closest('.kpi-card').querySelector('.value');
        if (valueElement) {
            valueElement.textContent = Math.round(kpiValues['roi']) + '%';
            updateCardStatus(roiCard.closest('.kpi-card'), kpiValues['roi'], 300);
        }
    }
}

function updateCardStatus(card, value, target, isInverse = false) {
    const ratio = isInverse ? target / value : value / target;
    
    if (ratio >= 1.1) {
        card.setAttribute('data-status', 'excellent');
    } else if (ratio >= 0.9) {
        card.setAttribute('data-status', 'good');
    } else {
        card.setAttribute('data-status', 'warning');
    }
}

// Utility functions
function formatCurrency(value) {
    return new Intl.NumberFormat('pt-BR', {
        style: 'currency',
        currency: 'BRL',
        minimumFractionDigits: 0
    }).format(value);
}

function formatPercentage(value) {
    return `${value.toFixed(1)}%`;
}

function formatNumber(value) {
    return new Intl.NumberFormat('pt-BR').format(value);
}

// Export functions for testing
if (typeof module !== 'undefined' && module.exports) {
    module.exports = {
        initializeDashboard,
        createSparkline,
        formatCurrency,
        formatPercentage,
        formatNumber
    };
}