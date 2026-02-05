import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/talk_post.dart';
import '../../providers/talk_provider.dart';
import '../../services/talk_service.dart';

class TalkPostDetailScreen extends ConsumerStatefulWidget {
  final String postId;

  const TalkPostDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<TalkPostDetailScreen> createState() => _TalkPostDetailScreenState();
}

class _TalkPostDetailScreenState extends ConsumerState<TalkPostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  bool _isLiked = false;
  bool _isSubmittingComment = false;
  String? _replyToCommentId;
  String? _replyToAuthor;

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postAsync = ref.watch(postDetailProvider(widget.postId));
    final commentsState = ref.watch(commentsProvider(widget.postId));

    return postAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, s) => Scaffold(
        appBar: AppBar(title: const Text('오류')),
        body: Center(child: Text('게시글을 불러올 수 없습니다: $e')),
      ),
      data: (post) {
        if (post == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('삭제된 게시글')),
            body: const Center(child: Text('삭제된 게시글입니다')),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              post.category.displayName,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.black87),
                onPressed: () => _sharePost(post),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.black87),
                onPressed: () => _showMoreOptions(post),
              ),
            ],
          ),
          body: Column(
            children: [
              // 본문
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(postDetailProvider(widget.postId));
                    ref.read(commentsProvider(widget.postId).notifier).loadComments();
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 작성자 정보
                        _buildAuthorSection(post),
                        const Divider(height: 1),
                        // 제목
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            post.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                        ),
                        // 내용
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            post.content,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              height: 1.6,
                            ),
                          ),
                        ),
                        // 이미지
                        if (post.imageUrls.isNotEmpty) _buildImages(post.imageUrls),
                        // 태그
                        if (post.tags.isNotEmpty) _buildTags(post.tags),
                        const SizedBox(height: 24),
                        // 통계 & 좋아요
                        _buildStats(post),
                        const SizedBox(height: 16),
                        // 좋아요/댓글 버튼
                        _buildActionButtons(post),
                        const SizedBox(height: 24),
                        const Divider(height: 1),
                        // 댓글 섹션
                        _buildCommentsSection(commentsState),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ),
              // 댓글 입력
              _buildCommentInput(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAuthorSection(TalkPost post) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF1E4A6E).withValues(alpha: 0.1),
            child: Text(
              post.authorName.isNotEmpty ? post.authorName[0] : '?',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E4A6E),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.authorName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  _formatFullTime(post.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E4A6E).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${post.category.emoji} ${post.category.displayName}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF1E4A6E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImages(List<String> imageUrls) {
    return Column(
      children: [
        const SizedBox(height: 16),
        ...imageUrls.map((url) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(Icons.image, size: 48, color: Colors.grey),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTags(List<String> tags) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: tags.map((tag) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '#$tag',
              style: TextStyle(fontSize: 13, color: Colors.blue.shade600),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStats(TalkPost post) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatChip(Icons.visibility, '조회 ${post.viewCount}'),
          const SizedBox(width: 12),
          _buildStatChip(Icons.favorite, '좋아요 ${post.likeCount + (_isLiked ? 1 : 0)}'),
          const SizedBox(width: 12),
          _buildStatChip(Icons.chat_bubble, '댓글 ${post.commentCount}'),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(TalkPost post) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _toggleLike(post),
              icon: Icon(
                _isLiked ? Icons.favorite : Icons.favorite_border,
                color: _isLiked ? Colors.red : Colors.grey,
              ),
              label: Text(
                _isLiked ? '좋아요 취소' : '좋아요',
                style: TextStyle(
                  color: _isLiked ? Colors.red : Colors.grey.shade700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: _isLiked ? Colors.red : Colors.grey.shade300,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                _commentFocusNode.requestFocus();
              },
              icon: Icon(Icons.chat_bubble_outline, color: Colors.grey.shade700),
              label: Text(
                '댓글 작성',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection(CommentsState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text(
                '댓글',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Text(
                '${state.comments.length}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade600,
                ),
              ),
            ],
          ),
        ),
        if (state.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (state.comments.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    '첫 번째 댓글을 남겨보세요!',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          )
        else
          ...state.comments.map((comment) => _buildCommentItem(comment)),
      ],
    );
  }

  Widget _buildCommentItem(TalkComment comment) {
    final isReply = comment.parentCommentId != null;

    return Container(
      padding: EdgeInsets.only(
        left: isReply ? 48 : 16,
        right: 16,
        top: 12,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: isReply ? Colors.grey.shade50 : Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: isReply ? 14 : 16,
            backgroundColor: const Color(0xFF1E4A6E).withValues(alpha: 0.1),
            child: Text(
              comment.authorName.isNotEmpty ? comment.authorName[0] : '?',
              style: TextStyle(
                fontSize: isReply ? 10 : 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E4A6E),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.authorName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(comment.createdAt),
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        children: [
                          Icon(Icons.favorite_border, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            comment.likeCount.toString(),
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (!isReply)
                      GestureDetector(
                        onTap: () => _setReplyTo(comment),
                        child: Text(
                          '답글',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: 18, color: Colors.grey.shade400),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'report', child: Text('신고')),
            ],
            onSelected: (value) {
              if (value == 'report') {
                _reportComment(comment);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_replyToAuthor != null)
            Container(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    '@$_replyToAuthor에게 답글',
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade600),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _clearReplyTo,
                    child: Icon(Icons.close, size: 16, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _commentController,
                    focusNode: _commentFocusNode,
                    decoration: const InputDecoration(
                      hintText: '댓글을 입력하세요...',
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _submitComment(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _isSubmittingComment
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      onPressed: _submitComment,
                      icon: const Icon(Icons.send),
                      color: const Color(0xFF1E4A6E),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  void _setReplyTo(TalkComment comment) {
    setState(() {
      _replyToCommentId = comment.id;
      _replyToAuthor = comment.authorName;
    });
    _commentFocusNode.requestFocus();
  }

  void _clearReplyTo() {
    setState(() {
      _replyToCommentId = null;
      _replyToAuthor = null;
    });
  }

  Future<void> _toggleLike(TalkPost post) async {
    setState(() {
      _isLiked = !_isLiked;
    });

    try {
      final talkService = TalkService();
      await talkService.toggleLike(post.id);
    } catch (e) {
      // 실패 시 롤백
      setState(() {
        _isLiked = !_isLiked;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('좋아요 처리에 실패했습니다: $e')),
        );
      }
    }
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() {
      _isSubmittingComment = true;
    });

    try {
      final commentsNotifier = ref.read(commentsProvider(widget.postId).notifier);
      await commentsNotifier.addComment(
        authorId: 'current_user', // 실제로는 인증된 사용자 ID
        authorName: '강인이팬', // 실제로는 사용자 닉네임
        content: content,
        parentCommentId: _replyToCommentId,
      );

      _commentController.clear();
      _clearReplyTo();
      _commentFocusNode.unfocus();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('댓글이 등록되었습니다'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('댓글 등록에 실패했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingComment = false;
        });
      }
    }
  }

  void _sharePost(TalkPost post) {
    Share.share(
      '${post.title}\n\n${post.content}\n\nK-Player Tracker에서 확인하세요!',
      subject: post.title,
    );
  }

  void _reportComment(TalkComment comment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('댓글 신고'),
        content: const Text('이 댓글을 신고하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('신고가 접수되었습니다')),
              );
            },
            child: const Text('신고', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}분 전';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}시간 전';
    } else {
      return '${diff.inDays}일 전';
    }
  }

  String _formatFullTime(DateTime dateTime) {
    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  void _showMoreOptions(TalkPost post) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.bookmark_border),
                title: const Text('북마크'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('북마크에 추가되었습니다')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('링크 복사'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('링크가 복사되었습니다')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.flag_outlined, color: Colors.red),
                title: const Text('신고', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _showReportDialog(post);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showReportDialog(TalkPost post) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('게시글 신고'),
        content: const Text('이 게시글을 신고하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('신고가 접수되었습니다')),
              );
            },
            child: const Text('신고', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
