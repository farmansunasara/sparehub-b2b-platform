// Theme configuration shared between admin panel and mobile app
const theme = {
    colors: {
        // Primary Colors
        primary: {
            50: '#eef2ff',
            100: '#e0e7ff',
            200: '#c7d2fe',
            300: '#a5b4fc',
            400: '#818cf8',
            500: '#6366f1',  // Main primary color
            600: '#4f46e5',
            700: '#4338ca',
            800: '#3730a3',
            900: '#312e81'
        },
        
        // Secondary Colors
        secondary: {
            50: '#f8fafc',
            100: '#f1f5f9',
            200: '#e2e8f0',
            300: '#cbd5e1',
            400: '#94a3b8',
            500: '#64748b',  // Main secondary color
            600: '#475569',
            700: '#334155',
            800: '#1e293b',
            900: '#0f172a'
        },
        
        // Accent Colors
        accent: {
            success: '#10b981',  // Green
            warning: '#f59e0b',  // Yellow
            error: '#ef4444',    // Red
            info: '#3b82f6'      // Blue
        },
        
        // Background Colors
        background: {
            primary: '#ffffff',
            secondary: '#f9fafb',
            tertiary: '#f3f4f6'
        },
        
        // Text Colors
        text: {
            primary: '#111827',
            secondary: '#4b5563',
            tertiary: '#9ca3af',
            inverse: '#ffffff'
        }
    },
    
    // Typography
    typography: {
        fontFamily: {
            primary: 'Inter, sans-serif',
            secondary: 'Roboto, sans-serif'
        },
        fontSize: {
            xs: '0.75rem',    // 12px
            sm: '0.875rem',   // 14px
            base: '1rem',     // 16px
            lg: '1.125rem',   // 18px
            xl: '1.25rem',    // 20px
            '2xl': '1.5rem',  // 24px
            '3xl': '1.875rem' // 30px
        },
        fontWeight: {
            light: '300',
            normal: '400',
            medium: '500',
            semibold: '600',
            bold: '700'
        }
    },
    
    // Spacing
    spacing: {
        0: '0',
        1: '0.25rem',  // 4px
        2: '0.5rem',   // 8px
        3: '0.75rem',  // 12px
        4: '1rem',     // 16px
        5: '1.25rem',  // 20px
        6: '1.5rem',   // 24px
        8: '2rem',     // 32px
        10: '2.5rem',  // 40px
        12: '3rem'     // 48px
    },
    
    // Border Radius
    borderRadius: {
        none: '0',
        sm: '0.125rem',    // 2px
        base: '0.25rem',   // 4px
        md: '0.375rem',    // 6px
        lg: '0.5rem',      // 8px
        xl: '0.75rem',     // 12px
        '2xl': '1rem',     // 16px
        full: '9999px'
    },
    
    // Shadows
    shadows: {
        sm: '0 1px 2px 0 rgba(0, 0, 0, 0.05)',
        base: '0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06)',
        md: '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)',
        lg: '0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05)',
        xl: '0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04)'
    },
    
    // Transitions
    transitions: {
        base: '150ms cubic-bezier(0.4, 0, 0.2, 1)',
        smooth: '300ms cubic-bezier(0.4, 0, 0.2, 1)',
        slow: '500ms cubic-bezier(0.4, 0, 0.2, 1)'
    },
    
    // Z-index
    zIndex: {
        0: '0',
        10: '10',
        20: '20',
        30: '30',
        40: '40',
        50: '50',
        auto: 'auto'
    }
};

// Export theme configuration
if (typeof module !== 'undefined' && module.exports) {
    module.exports = theme;
} else if (typeof window !== 'undefined') {
    window.spareHubTheme = theme;
}
