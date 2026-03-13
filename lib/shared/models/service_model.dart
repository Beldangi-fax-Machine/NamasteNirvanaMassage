class ServiceModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int durationMinutes;
  final String? imageUrl;
  final String category;
  final bool isPopular;
  final List<String> benefits;

  const ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
    this.imageUrl,
    required this.category,
    this.isPopular = false,
    this.benefits = const [],
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      durationMinutes: json['duration_minutes'] as int,
      imageUrl: json['image_url'] as String?,
      category: json['category'] as String,
      isPopular: json['is_popular'] as bool? ?? false,
      benefits: (json['benefits'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'duration_minutes': durationMinutes,
      'image_url': imageUrl,
      'category': category,
      'is_popular': isPopular,
      'benefits': benefits,
    };
  }

  String get formattedPrice => '\$${price.toStringAsFixed(0)}';
  String get formattedDuration => '$durationMinutes min';

  // Sample data for the app
  static List<ServiceModel> get sampleServices => [
        const ServiceModel(
          id: 'swedish',
          name: 'Swedish Massage',
          description:
              'A gentle, relaxing full-body massage using long strokes and kneading techniques to ease tension and promote circulation.',
          price: 85,
          durationMinutes: 60,
          category: 'Relaxation',
          isPopular: true,
          benefits: [
            'Reduces stress',
            'Improves circulation',
            'Eases muscle tension',
            'Promotes relaxation',
          ],
        ),
        const ServiceModel(
          id: 'deep-tissue',
          name: 'Deep Tissue Massage',
          description:
              'Targets deeper muscle layers to release chronic tension, perfect for athletes and those with persistent pain.',
          price: 95,
          durationMinutes: 60,
          category: 'Therapeutic',
          benefits: [
            'Relieves chronic pain',
            'Breaks up scar tissue',
            'Improves mobility',
            'Reduces inflammation',
          ],
        ),
        const ServiceModel(
          id: 'hot-stone',
          name: 'Hot Stone Therapy',
          description:
              'Heated basalt stones placed on key points to melt away stress while promoting deep relaxation and healing.',
          price: 110,
          durationMinutes: 75,
          category: 'Specialty',
          isPopular: true,
          benefits: [
            'Deep muscle relaxation',
            'Improved sleep',
            'Pain relief',
            'Stress reduction',
          ],
        ),
        const ServiceModel(
          id: 'aromatherapy',
          name: 'Aromatherapy Massage',
          description:
              'Essential oils combined with gentle massage techniques for enhanced relaxation and emotional healing.',
          price: 90,
          durationMinutes: 60,
          category: 'Relaxation',
          benefits: [
            'Mood enhancement',
            'Stress relief',
            'Better sleep',
            'Skin nourishment',
          ],
        ),
        const ServiceModel(
          id: 'thai',
          name: 'Thai Massage',
          description:
              'Ancient healing art combining yoga-like stretching, acupressure, and energy work for total body renewal.',
          price: 100,
          durationMinutes: 90,
          category: 'Therapeutic',
          benefits: [
            'Increased flexibility',
            'Energy balance',
            'Improved posture',
            'Mental clarity',
          ],
        ),
        const ServiceModel(
          id: 'couples',
          name: 'Couples Massage',
          description:
              'Share a blissful experience with your partner in our serene couples suite with synchronized treatments.',
          price: 180,
          durationMinutes: 60,
          category: 'Specialty',
          isPopular: true,
          benefits: [
            'Shared experience',
            'Relationship bonding',
            'Simultaneous relaxation',
            'Special occasions',
          ],
        ),
        const ServiceModel(
          id: 'prenatal',
          name: 'Prenatal Massage',
          description:
              'Specially designed for expecting mothers to relieve pregnancy-related discomfort with gentle techniques.',
          price: 95,
          durationMinutes: 60,
          category: 'Specialty',
          benefits: [
            'Reduces swelling',
            'Eases back pain',
            'Improves sleep',
            'Reduces anxiety',
          ],
        ),
        const ServiceModel(
          id: 'signature',
          name: 'Signature Nirvana',
          description:
              'Our exclusive signature treatment combining multiple massage styles with aromatherapy and hot stones.',
          price: 150,
          durationMinutes: 90,
          category: 'Premium',
          isPopular: true,
          benefits: [
            'Ultimate relaxation',
            'Full body treatment',
            'Premium products',
            'Customized experience',
          ],
        ),
      ];
}
