// Copy to clipboard functionality
function copyCode(button, codeId) {
    const code = document.getElementById(codeId).textContent;
    
    navigator.clipboard.writeText(code).then(() => {
        const originalText = button.textContent;
        button.textContent = '✓ Copied!';
        button.style.background = 'var(--success)';
        
        setTimeout(() => {
            button.textContent = originalText;
            button.style.background = 'var(--primary)';
        }, 2000);
    }).catch(err => {
        console.error('Failed to copy:', err);
        button.textContent = '✗ Failed';
        button.style.background = 'var(--danger)';
        
        setTimeout(() => {
            button.textContent = 'Copy';
            button.style.background = 'var(--primary)';
        }, 2000);
    });
}

// Smooth scroll for anchor links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        e.preventDefault();
        const target = document.querySelector(this.getAttribute('href'));
        if (target) {
            target.scrollIntoView({
                behavior: 'smooth',
                block: 'start'
            });
        }
    });
});

// Intersection Observer for fade-in animations
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px'
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.style.opacity = '1';
            entry.target.style.transform = 'translateY(0)';
        }
    });
}, observerOptions);

// Observe all fade-in-up elements
document.querySelectorAll('.fade-in-up').forEach(el => {
    el.style.opacity = '0';
    el.style.transform = 'translateY(20px)';
    el.style.transition = 'opacity 0.6s ease-out, transform 0.6s ease-out';
    observer.observe(el);
});

// Add active state to nav links based on scroll position
window.addEventListener('scroll', () => {
    const sections = document.querySelectorAll('section[id]');
    const navLinks = document.querySelectorAll('.nav-links a');
    
    let current = '';
    sections.forEach(section => {
        const sectionTop = section.offsetTop;
        const sectionHeight = section.clientHeight;
        if (window.pageYOffset >= sectionTop - 100) {
            current = section.getAttribute('id');
        }
    });
    
    navLinks.forEach(link => {
        link.classList.remove('active');
        if (link.getAttribute('href').includes(current)) {
            link.classList.add('active');
        }
    });
});

// Add parallax effect to hero section
window.addEventListener('scroll', () => {
    const hero = document.querySelector('.hero');
    if (hero) {
        const scrolled = window.pageYOffset;
        hero.style.transform = `translateY(${scrolled * 0.5}px)`;
        hero.style.opacity = 1 - (scrolled / 500);
    }
});

// Console easter egg
console.log('%c🚀 HAProxy & Marzban Automation Suite', 'font-size: 20px; font-weight: bold; color: #6366f1;');
console.log('%cEnhanced Edition v2.0.0', 'font-size: 14px; color: #8b5cf6;');
console.log('%cMade with ❤️ by Tawana Mohammadi', 'font-size: 12px; color: #06b6d4;');
console.log('%cGitHub: https://github.com/tawanamohammadi/haprox-marz', 'font-size: 12px; color: #10b981;');
