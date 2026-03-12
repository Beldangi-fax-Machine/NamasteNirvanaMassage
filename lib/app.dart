import 'dart:html';

/// Main application class for Namaste Nirvana Massage website
class NamasteNirvanaApp {
  /// List of massage services offered
  final List<MassageService> services = [
    MassageService(
      name: 'Swedish Massage',
      description: 'A gentle, relaxing full-body massage using long strokes and kneading techniques.',
      price: 85,
      duration: 60,
    ),
    MassageService(
      name: 'Deep Tissue Massage',
      description: 'Targets deeper muscle layers to relieve chronic tension and pain.',
      price: 95,
      duration: 60,
    ),
    MassageService(
      name: 'Hot Stone Therapy',
      description: 'Heated stones placed on key points to melt away stress and tension.',
      price: 110,
      duration: 75,
    ),
    MassageService(
      name: 'Aromatherapy Massage',
      description: 'Essential oils combined with massage for enhanced relaxation and healing.',
      price: 90,
      duration: 60,
    ),
    MassageService(
      name: 'Thai Massage',
      description: 'Ancient healing technique combining stretching, acupressure, and yoga.',
      price: 100,
      duration: 90,
    ),
    MassageService(
      name: 'Couples Massage',
      description: 'Share a relaxing experience with your partner in our serene couples suite.',
      price: 180,
      duration: 60,
    ),
  ];

  /// Initialize the application
  void initialize() {
    _renderServices();
    _setupEventListeners();
    _setupSmoothScrolling();
  }

  /// Render service cards to the DOM
  void _renderServices() {
    final container = querySelector('#services-container');
    if (container == null) return;

    for (final service in services) {
      final card = DivElement()
        ..className = 'service-card'
        ..innerHtml = '''
          <h3>${service.name}</h3>
          <p>${service.description}</p>
          <p class="price">\$${service.price} / ${service.duration} min</p>
        ''';
      container.append(card);
    }
  }

  /// Setup event listeners for interactive elements
  void _setupEventListeners() {
    // Book Now button
    final bookButton = querySelector('#book-now-btn');
    bookButton?.onClick.listen((_) {
      _scrollToSection('#contact');
    });

    // Contact form submission
    final contactForm = querySelector('#contact-form') as FormElement?;
    contactForm?.onSubmit.listen((event) {
      event.preventDefault();
      _handleFormSubmission();
    });
  }

  /// Setup smooth scrolling for navigation links
  void _setupSmoothScrolling() {
    final navLinks = querySelectorAll('.nav-links a');
    for (final link in navLinks) {
      link.onClick.listen((event) {
        event.preventDefault();
        final href = link.getAttribute('href');
        if (href != null) {
          _scrollToSection(href);
        }
      });
    }
  }

  /// Scroll to a specific section smoothly
  void _scrollToSection(String selector) {
    final element = querySelector(selector);
    element?.scrollIntoView({'behavior': 'smooth'});
  }

  /// Handle contact form submission
  void _handleFormSubmission() {
    final nameInput = querySelector('#name') as InputElement?;
    final emailInput = querySelector('#email') as InputElement?;
    final messageInput = querySelector('#message') as TextAreaElement?;

    final name = nameInput?.value ?? '';
    final email = emailInput?.value ?? '';
    final message = messageInput?.value ?? '';

    if (name.isNotEmpty && email.isNotEmpty && message.isNotEmpty) {
      print('Form submitted: $name, $email');

      // Clear form
      nameInput?.value = '';
      emailInput?.value = '';
      messageInput?.value = '';

      // Show success message
      window.alert('Thank you for your message, $name! We will get back to you soon.');
    }
  }
}

/// Represents a massage service offered
class MassageService {
  final String name;
  final String description;
  final int price;
  final int duration;

  MassageService({
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
  });
}
