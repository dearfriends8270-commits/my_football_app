import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/talk_post.dart';
import '../../providers/talk_provider.dart';
import '../../services/talk_service.dart';

class TalkWriteScreen extends ConsumerStatefulWidget {
  final String playerId;
  final String playerName;

  const TalkWriteScreen({
    super.key,
    required this.playerId,
    required this.playerName,
  });

  @override
  ConsumerState<TalkWriteScreen> createState() => _TalkWriteScreenState();
}

class _TalkWriteScreenState extends ConsumerState<TalkWriteScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  TalkCategory _selectedCategory = TalkCategory.free;
  final List<String> _tags = [];
  final List<XFile> _selectedImages = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () {
            _showExitConfirmation();
          },
        ),
        title: const Text(
          '글쓰기',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          _isSubmitting
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : TextButton(
                  onPressed: _canSubmit() ? _submitPost : null,
                  child: Text(
                    '등록',
                    style: TextStyle(
                      color: _canSubmit() ? const Color(0xFF1E4A6E) : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 카테고리 선택
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '카테고리',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: TalkCategory.values
                        .where((c) => c != TalkCategory.all)
                        .map((category) {
                      final isSelected = _selectedCategory == category;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF1E4A6E)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
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
                                category.emoji,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                category.displayName,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isSelected ? Colors.white : Colors.black87,
                                  fontWeight:
                                      isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedCategory.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // 제목
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: TextField(
                controller: _titleController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: '제목을 입력하세요',
                  hintStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                maxLength: 100,
                buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                  return Text(
                    '$currentLength/$maxLength',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  );
                },
              ),
            ),

            // 내용
            Container(
              padding: const EdgeInsets.all(16),
              constraints: const BoxConstraints(minHeight: 200),
              child: TextField(
                controller: _contentController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: '내용을 입력하세요...',
                  hintStyle: TextStyle(fontSize: 16),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.6,
                ),
                maxLines: null,
                keyboardType: TextInputType.multiline,
              ),
            ),

            // 이미지 첨부
            if (_selectedImages.isNotEmpty)
              Container(
                height: 120,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(_selectedImages[index].path),
                              fit: BoxFit.cover,
                              onError: (exception, stackTrace) {},
                            ),
                          ),
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                        Positioned(
                          top: 4,
                          right: 12,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImages.removeAt(index);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

            // 태그
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '태그',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller: _tagController,
                            decoration: const InputDecoration(
                              hintText: '태그 입력 후 추가',
                              border: InputBorder.none,
                              prefixText: '# ',
                            ),
                            onSubmitted: (value) => _addTag(value),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _addTag(_tagController.text),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E4A6E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('추가', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_tags.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '#$tag',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.blue.shade600,
                                ),
                              ),
                              const SizedBox(width: 6),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _tags.remove(tag);
                                  });
                                },
                                child: Icon(
                                  Icons.close,
                                  size: 14,
                                  color: Colors.blue.shade600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    '최대 5개까지 추가할 수 있어요 (${_tags.length}/5)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: _pickImageFromGallery,
                icon: const Icon(Icons.image_outlined),
                color: Colors.grey.shade600,
                tooltip: '갤러리에서 선택',
              ),
              IconButton(
                onPressed: _pickImageFromCamera,
                icon: const Icon(Icons.camera_alt_outlined),
                color: Colors.grey.shade600,
                tooltip: '카메라로 촬영',
              ),
              const SizedBox(width: 8),
              if (_selectedImages.isNotEmpty)
                Text(
                  '이미지 ${_selectedImages.length}/5',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              const Spacer(),
              Text(
                '${_contentController.text.length} 자',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addTag(String value) {
    final tag = value.trim();
    if (tag.isNotEmpty && !_tags.contains(tag) && _tags.length < 5) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
    } else if (_tags.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('태그는 최대 5개까지 추가할 수 있어요')),
      );
    } else if (_tags.contains(tag)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미 추가된 태그입니다')),
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지는 최대 5장까지 첨부할 수 있어요')),
      );
      return;
    }

    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (images.isNotEmpty) {
        final remainingSlots = 5 - _selectedImages.length;
        final imagesToAdd = images.take(remainingSlots).toList();
        setState(() {
          _selectedImages.addAll(imagesToAdd);
        });

        if (images.length > remainingSlots) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('이미지는 최대 5장까지 첨부할 수 있어요 (${imagesToAdd.length}장 추가됨)'),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미지를 불러오는데 실패했습니다')),
        );
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지는 최대 5장까지 첨부할 수 있어요')),
      );
      return;
    }

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('카메라를 사용할 수 없습니다')),
        );
      }
    }
  }

  bool _canSubmit() {
    return _titleController.text.trim().isNotEmpty &&
        _contentController.text.trim().isNotEmpty &&
        !_isSubmitting;
  }

  Future<void> _submitPost() async {
    if (!_canSubmit()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final talkService = TalkService();

      // 게시글 생성
      final post = await talkService.createPost(
        authorId: 'current_user', // 실제로는 인증된 사용자 ID 사용
        authorName: '강인이팬', // 실제로는 사용자 닉네임 사용
        playerId: widget.playerId,
        category: _selectedCategory,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        imageUrls: _selectedImages.map((f) => f.path).toList(),
        tags: _tags,
      );

      // Talk 목록 새로고침
      ref.read(talkPostsProvider(widget.playerId).notifier).addPost(post);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('게시글이 등록되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(post); // 생성된 게시글 반환
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('게시글 등록에 실패했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showExitConfirmation() {
    if (_titleController.text.isEmpty && _contentController.text.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('작성 중인 글이 있어요'),
          content: const Text('지금 나가면 작성 중인 내용이 사라져요. 정말 나가시겠어요?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('계속 작성'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text(
                '나가기',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
