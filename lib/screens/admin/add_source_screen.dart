import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../models/crawl_source.dart';
import '../../providers/admin_provider.dart';

class AddSourceScreen extends ConsumerStatefulWidget {
  const AddSourceScreen({super.key});

  @override
  ConsumerState<AddSourceScreen> createState() => _AddSourceScreenState();
}

class _AddSourceScreenState extends ConsumerState<AddSourceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _baseUrlController = TextEditingController();
  final _feedUrlController = TextEditingController();

  CrawlSourceType _selectedType = CrawlSourceType.rss;
  String _selectedLanguage = 'en';
  bool _isActive = true;
  bool _isLoading = false;

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English'},
    {'code': 'ko', 'name': '한국어'},
    {'code': 'fr', 'name': 'Français'},
    {'code': 'de', 'name': 'Deutsch'},
    {'code': 'es', 'name': 'Español'},
    {'code': 'it', 'name': 'Italiano'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _baseUrlController.dispose();
    _feedUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E4A6E),
        title: const Text(
          '새 소스 추가',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 기본 정보
              _buildSectionCard(
                title: '기본 정보',
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '소스 이름',
                      hintText: 'BBC Sport',
                      prefixIcon: Icon(Icons.label),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '소스 이름을 입력해주세요';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _baseUrlController,
                    decoration: const InputDecoration(
                      labelText: '기본 URL',
                      hintText: 'https://bbc.com/sport',
                      prefixIcon: Icon(Icons.link),
                    ),
                    keyboardType: TextInputType.url,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '기본 URL을 입력해주세요';
                      }
                      if (!Uri.tryParse(value)!.isAbsolute) {
                        return '올바른 URL 형식이 아닙니다';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _feedUrlController,
                    decoration: const InputDecoration(
                      labelText: '피드 URL',
                      hintText: 'https://feeds.bbc.co.uk/sport/rss.xml',
                      prefixIcon: Icon(Icons.rss_feed),
                    ),
                    keyboardType: TextInputType.url,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '피드 URL을 입력해주세요';
                      }
                      return null;
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 소스 타입
              _buildSectionCard(
                title: '소스 타입',
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: CrawlSourceType.values.map((type) {
                      final isSelected = _selectedType == type;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedType = type;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF1E4A6E)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF1E4A6E)
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                type.icon,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                type.displayName,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 언어 선택
              _buildSectionCard(
                title: '언어',
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedLanguage,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.language),
                    ),
                    items: _languages.map((lang) {
                      return DropdownMenuItem(
                        value: lang['code'],
                        child: Text(lang['name']!),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedLanguage = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 활성화 상태
              _buildSectionCard(
                title: '상태',
                children: [
                  SwitchListTile(
                    title: const Text('소스 활성화'),
                    subtitle: Text(
                      _isActive ? '이 소스에서 뉴스를 수집합니다' : '이 소스에서 뉴스를 수집하지 않습니다',
                    ),
                    value: _isActive,
                    onChanged: (value) {
                      setState(() {
                        _isActive = value;
                      });
                    },
                    activeColor: const Color(0xFF1E4A6E),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 저장 버튼
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveSource,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E4A6E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text(
                          '소스 추가',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Future<void> _saveSource() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final source = CrawlSource(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      baseUrl: _baseUrlController.text.trim(),
      feedUrl: _feedUrlController.text.trim(),
      type: _selectedType,
      language: _selectedLanguage,
      isActive: _isActive,
      successCount: 0,
      failCount: 0,
      targetPlayerIds: [],
    );

    final result = await ref.read(adminSourcesProvider.notifier).addSource(source);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('소스가 추가되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('소스 추가에 실패했습니다'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
