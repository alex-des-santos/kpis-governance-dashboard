// Mock Data for Dashboard Demo
const mockData = {
    // KPIs Data
    kpis: {
        conversion_rate: {
            current: 12.5,
            target: 15,
            trend: 'up',
            sparkline: [8.5, 9.2, 10.1, 11.3, 10.8, 12.1, 12.5]
        },
        cac: {
            current: 850,
            target: 500,
            trend: 'down',
            sparkline: [950, 900, 875, 825, 800, 830, 850]
        },
        mrr: {
            current: 285000,
            target: 250000,
            trend: 'up',
            sparkline: [220000, 235000, 248000, 265000, 270000, 278000, 285000]
        },
        sla_whatsapp: {
            current: 94,
            target: 90,
            trend: 'up',
            sparkline: [88, 89, 91, 92, 93, 94, 94]
        },
        lead_time: {
            current: 7.2,
            target: 5,
            trend: 'stable',
            sparkline: [8.1, 7.8, 7.5, 7.2, 7.0, 7.1, 7.2]
        },
        gross_margin: {
            current: 68,
            target: 60,
            trend: 'up',
            sparkline: [62, 64, 65, 66, 67, 68, 68]
        },
        events_roi: {
            current: 245,
            target: 300,
            trend: 'up',
            sparkline: [180, 200, 220, 230, 235, 240, 245]
        }
    },

    // Sales Funnel Data
    salesFunnel: {
        labels: ['Leads', 'Qualificados', 'Oportunidades', 'Propostas', 'Fechados'],
        values: [1000, 400, 200, 120, 50],
        colors: ['#3498db', '#2ecc71', '#f39c12', '#e67e22', '#e74c3c']
    },

    // Lead Sources Data
    leadSources: {
        labels: ['Ads', 'WhatsApp', 'Site', 'SDR', 'Indicações', 'Eventos'],
        values: [35, 25, 15, 12, 8, 5],
        colors: ['#3498db', '#2ecc71', '#f39c12', '#e67e22', '#9b59b6', '#e74c3c']
    },

    // MRR Evolution (12 months)
    mrrEvolution: {
        labels: ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez'],
        values: [180000, 195000, 210000, 225000, 240000, 255000, 270000, 285000, 300000, 315000, 330000, 345000],
        targets: [200000, 210000, 220000, 230000, 240000, 250000, 260000, 270000, 280000, 290000, 300000, 310000]
    },

    // Response Time Data (7 days)
    responseTime: {
        labels: ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Dom'],
        avgTime: [12, 15, 18, 14, 16, 10, 8],
        slaTarget: 15,
        volume: [120, 135, 150, 140, 145, 80, 45]
    },

    // Channel Performance
    channelPerformance: {
        ads: {
            leads: 350,
            conversions: 45,
            cost: 25000,
            roi: 180
        },
        whatsapp: {
            leads: 250,
            conversions: 35,
            cost: 5000,
            roi: 320
        },
        sdr: {
            leads: 120,
            conversions: 22,
            cost: 15000,
            roi: 145
        },
        events: {
            leads: 50,
            conversions: 12,
            cost: 8000,
            roi: 245
        }
    },

    // Time Series Data for Trends
    trends: {
        last30Days: {
            labels: generateDateLabels(30),
            conversion: generateTrendData(30, 10, 15, 0.5),
            mrr: generateTrendData(30, 270000, 285000, 5000),
            sla: generateTrendData(30, 90, 95, 2)
        }
    }
};

// Helper functions
function generateDateLabels(days) {
    const labels = [];
    const today = new Date();
    for (let i = days - 1; i >= 0; i--) {
        const date = new Date(today);
        date.setDate(today.getDate() - i);
        labels.push(date.toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit' }));
    }
    return labels;
}

function generateTrendData(days, min, max, variance) {
    const data = [];
    let current = min + (max - min) * Math.random();
    
    for (let i = 0; i < days; i++) {
        const change = (Math.random() - 0.5) * variance;
        current += change;
        current = Math.max(min, Math.min(max, current));
        data.push(Number(current.toFixed(2)));
    }
    
    return data;
}

// Export for use in other files
if (typeof module !== 'undefined' && module.exports) {
    module.exports = mockData;
}
