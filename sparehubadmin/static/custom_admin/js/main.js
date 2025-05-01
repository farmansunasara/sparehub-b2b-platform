// Toast Notification System
const showToast = (message, type = 'info') => {
    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    toast.innerHTML = `
        <div class="flex items-center">
            <i class="fas fa-${type === 'success' ? 'check-circle' : type === 'error' ? 'exclamation-circle' : 'info-circle'} mr-2"></i>
            <span>${message}</span>
        </div>
    `;
    document.body.appendChild(toast);
    
    setTimeout(() => {
        toast.style.animation = 'slideOut 0.3s ease forwards';
        setTimeout(() => toast.remove(), 300);
    }, 3000);
};

// Sidebar Toggle
document.addEventListener('DOMContentLoaded', () => {
    const sidebarToggle = document.querySelector('[data-sidebar-toggle]');
    const sidebar = document.querySelector('[data-sidebar]');
    
    if (sidebarToggle && sidebar) {
        sidebarToggle.addEventListener('click', () => {
            sidebar.classList.toggle('hidden');
            sidebar.classList.toggle('lg:block');
        });
    }
    
    // Active sidebar item
    const currentPath = window.location.pathname;
    document.querySelectorAll('.sidebar-item').forEach(item => {
        if (item.getAttribute('href') === currentPath) {
            item.classList.add('active');
        }
    });
});

// Data Table Search and Filter
const initializeDataTable = (tableId) => {
    const table = document.getElementById(tableId);
    if (!table) return;

    const searchInput = document.querySelector(`[data-search-table="${tableId}"]`);
    const filterSelects = document.querySelectorAll(`[data-filter-table="${tableId}"]`);
    
    if (searchInput) {
        searchInput.addEventListener('input', (e) => {
            const searchTerm = e.target.value.toLowerCase();
            const rows = table.querySelectorAll('tbody tr');
            
            rows.forEach(row => {
                const text = row.textContent.toLowerCase();
                row.style.display = text.includes(searchTerm) ? '' : 'none';
            });
        });
    }
    
    filterSelects.forEach(select => {
        select.addEventListener('change', () => {
            const filters = {};
            filterSelects.forEach(s => {
                if (s.value) filters[s.dataset.filterColumn] = s.value;
            });
            
            const rows = table.querySelectorAll('tbody tr');
            rows.forEach(row => {
                let show = true;
                for (const [column, value] of Object.entries(filters)) {
                    const cell = row.querySelector(`[data-column="${column}"]`);
                    if (cell && cell.textContent.toLowerCase() !== value.toLowerCase()) {
                        show = false;
                        break;
                    }
                }
                row.style.display = show ? '' : 'none';
            });
        });
    });
};

// Form Validation
const validateForm = (formId, rules) => {
    const form = document.getElementById(formId);
    if (!form) return;

    form.addEventListener('submit', (e) => {
        let isValid = true;
        const errors = {};

        for (const [field, validations] of Object.entries(rules)) {
            const input = form.querySelector(`[name="${field}"]`);
            if (!input) continue;

            const value = input.value.trim();
            const errorElement = form.querySelector(`[data-error="${field}"]`);

            validations.forEach(validation => {
                if (validation.required && !value) {
                    errors[field] = 'This field is required';
                    isValid = false;
                } else if (validation.pattern && !validation.pattern.test(value)) {
                    errors[field] = validation.message;
                    isValid = false;
                } else if (validation.minLength && value.length < validation.minLength) {
                    errors[field] = `Minimum length is ${validation.minLength} characters`;
                    isValid = false;
                }
            });

            if (errorElement) {
                errorElement.textContent = errors[field] || '';
            }
        }

        if (!isValid) {
            e.preventDefault();
            showToast('Please check the form for errors', 'error');
        }
    });
};

// Confirm Dialog
const confirmAction = (message, callback) => {
    const confirmed = window.confirm(message);
    if (confirmed && typeof callback === 'function') {
        callback();
    }
};

// Initialize Chart.js Charts
const initializeChart = (canvasId, config) => {
    const canvas = document.getElementById(canvasId);
    if (!canvas) return;

    return new Chart(canvas.getContext('2d'), {
        ...config,
        options: {
            ...config.options,
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                tooltip: {
                    backgroundColor: 'rgba(17, 24, 39, 0.9)',
                    titleColor: 'white',
                    bodyColor: 'white',
                    padding: 12,
                    borderRadius: 6,
                },
                ...config.options?.plugins,
            },
        },
    });
};

// Handle File Upload Preview
const initializeFileUpload = (inputId, previewId) => {
    const input = document.getElementById(inputId);
    const preview = document.getElementById(previewId);
    if (!input || !preview) return;

    input.addEventListener('change', (e) => {
        const file = e.target.files[0];
        if (!file) return;

        if (file.type.startsWith('image/')) {
            const reader = new FileReader();
            reader.onload = (e) => {
                preview.src = e.target.result;
                preview.style.display = 'block';
            };
            reader.readAsDataURL(file);
        }
    });
};

// Export functionality
window.adminUtils = {
    showToast,
    initializeDataTable,
    validateForm,
    confirmAction,
    initializeChart,
    initializeFileUpload,
};
