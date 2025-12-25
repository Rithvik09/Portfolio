# Portfolio Website

A modern, interactive, and colorful portfolio website showcasing your skills, experience, and projects.

## Features

- 🎨 **Beautiful Design**: Modern UI with gradient colors and smooth animations
- 📱 **Fully Responsive**: Works perfectly on all devices (desktop, tablet, mobile)
- ⚡ **Interactive Elements**: Smooth scrolling, typing effects, and hover animations
- 🌈 **Colorful Theme**: Vibrant gradient colors and visual effects
- 🚀 **Fast & Lightweight**: Optimized for performance
- ♿ **Accessible**: Built with accessibility in mind

## Sections

1. **Hero Section**: Eye-catching introduction with animated typing effect
2. **About**: Personal information and highlights
3. **Experience**: Timeline of your work experience
4. **Projects**: Showcase of your featured projects
5. **Skills**: Your technical skills and technologies
6. **Contact**: Contact form and social links

## Getting Started

1. Open `index.html` in your web browser
2. Customize the content with your information:
   - Update personal details in the HTML
   - Add your experience, projects, and skills
   - Replace placeholder images with your own

## Customization

### Update Personal Information

Edit `index.html` and replace:
- Name: "Rithvik Sriram" (already set)
- Email: "rithvikranga@gmail.com" (already set)
- LinkedIn: Your LinkedIn URL (already set)
- GitHub: Your GitHub URL (already set)

### Add Your Experience

In the Experience section, update the timeline items with your actual work history:

```html
<div class="timeline-item">
    <div class="timeline-content">
        <h3 class="timeline-title">Your Position</h3>
        <span class="timeline-company">@ Company Name</span>
        <span class="timeline-date">Month Year - Present</span>
        <!-- Add your details -->
    </div>
</div>
```

### Add Your Projects

Update the project cards with your actual projects:

```html
<div class="project-card">
    <h3 class="project-title">Your Project Name</h3>
    <p class="project-description">Project description</p>
    <div class="project-tech">
        <span class="tech-tag">Technology</span>
    </div>
</div>
```

### Update Skills

Modify the skills section to reflect your actual skills and proficiency levels:

```html
<div class="skill-item">
    <span class="skill-name">Skill Name</span>
    <div class="skill-bar">
        <div class="skill-progress" data-progress="90"></div>
    </div>
</div>
```

### Change Colors

Edit the CSS variables in `styles.css` to customize the color scheme:

```css
:root {
    --primary-color: #667eea;
    --secondary-color: #764ba2;
    --green: #64ffda;
    /* ... more colors */
}
```

## Browser Support

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)

## Technologies Used

- HTML5
- CSS3 (with CSS Variables and Animations)
- Vanilla JavaScript (No frameworks required!)

## Notes

- The contact form currently uses a mailto link. For production, you may want to integrate with a backend service or email API.
- All images are placeholders. Replace them with your actual photos.
- The typing effect cycles through different phrases - customize them in `script.js`.

## License

Feel free to use this portfolio template for your personal website!

---

Built with ❤️ for showcasing your work

