import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../app/theme.dart';
import '../../data/models/family_models.dart';
import '../providers/family_provider.dart';
import '../widgets/family_member_card.dart';
import '../widgets/invite_member_sheet.dart';
import '../widgets/member_role_selector.dart';
import '../widgets/pending_invite_card.dart';

/// Family Screen
/// Displays family info, members, pending invites with management options
class FamilyScreen extends ConsumerStatefulWidget {
  const FamilyScreen({super.key});

  @override
  ConsumerState<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends ConsumerState<FamilyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(familyStateProvider.notifier).loadFamily();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await ref.read(familyStateProvider.notifier).refresh();
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: SpendexColors.income,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: SpendexColors.expense,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SpendexTheme.radiusMd),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final familyState = ref.watch(familyStateProvider);

    ref.listen<FamilyState>(familyStateProvider, (prev, next) {
      if (next.successMessage != null && prev?.successMessage != next.successMessage) {
        _showSuccessSnackBar(next.successMessage!);
        ref.read(familyStateProvider.notifier).clearSuccessMessage();
      }
      if (next.error != null && prev?.error != next.error) {
        _showErrorSnackBar(next.error!);
        ref.read(familyStateProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: isDark ? SpendexColors.darkBackground : SpendexColors.lightBackground,
      appBar: AppBar(
        title: const Text('Family'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (familyState.hasFamily && familyState.isOwner)
            IconButton(
              icon: const Icon(Iconsax.setting_2),
              onPressed: () => _showFamilySettingsSheet(context, isDark),
            ),
          IconButton(
            icon: const Icon(Iconsax.refresh),
            onPressed: familyState.isLoading ? null : _refresh,
          ),
        ],
      ),
      body: familyState.isLoading && familyState.family == null
          ? _buildLoadingState()
          : familyState.hasFamily
              ? _buildFamilyContent(familyState, isDark)
              : _buildNoFamilyState(isDark),
      floatingActionButton: familyState.hasFamily && familyState.canManageMembers
          ? FloatingActionButton.extended(
              onPressed: () => _showInviteMemberSheet(context),
              icon: const Icon(Iconsax.user_add),
              label: const Text('Invite'),
              backgroundColor: SpendexColors.primary,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(color: SpendexColors.primary),
    );
  }

  Widget _buildNoFamilyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: SpendexColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(Iconsax.people, size: 56, color: SpendexColors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              'No Family Yet',
              style: SpendexTheme.headlineMedium.copyWith(
                color: isDark ? SpendexColors.darkTextPrimary : SpendexColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create a family to share finances with your loved ones or join an existing family via invite.',
              style: SpendexTheme.bodyMedium.copyWith(
                color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showCreateFamilyDialog(context, isDark),
              icon: const Icon(Iconsax.add),
              label: const Text('Create Family'),
              style: ElevatedButton.styleFrom(
                backgroundColor: SpendexColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () => _showJoinFamilyDialog(context, isDark),
              icon: const Icon(Iconsax.login),
              label: const Text('Join with Invite Code'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyContent(FamilyState state, bool isDark) {
    return RefreshIndicator(
      onRefresh: _refresh,
      color: SpendexColors.primary,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildFamilyHeader(state, isDark)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildTabs(isDark, state),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          _buildTabContent(state, isDark),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildFamilyHeader(FamilyState state, bool isDark) {
    final family = state.family;
    if (family == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: SpendexColors.primaryGradient,
        borderRadius: BorderRadius.circular(SpendexTheme.radiusXl),
        boxShadow: [
          BoxShadow(
            color: SpendexColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(SpendexTheme.radiusLg),
            ),
            child: const Icon(Iconsax.home_2, size: 36, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            family.name,
            style: SpendexTheme.headlineMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatItem(
                icon: Iconsax.people,
                value: '${family.memberCount}',
                label: 'Members',
              ),
              Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.3)),
              _buildStatItem(
                icon: Iconsax.send_2,
                value: '${state.pendingInvites.length}',
                label: 'Pending',
              ),
              Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.3)),
              _buildStatItem(
                icon: Iconsax.user_tick,
                value: state.currentUserMember?.role.label ?? 'Member',
                label: 'Your Role',
                isText: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    bool isText = false,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              value,
              style: SpendexTheme.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: isText ? 12 : 18,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: SpendexTheme.labelSmall.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildTabs(bool isDark, FamilyState state) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isDark ? SpendexColors.darkCard : SpendexColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: SpendexColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor:
            isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
        labelStyle: SpendexTheme.titleMedium,
        unselectedLabelStyle: SpendexTheme.titleMedium,
        tabs: [
          Tab(text: 'Members (${state.members.length})'),
          Tab(text: 'Invites (${state.pendingInvites.length})'),
        ],
      ),
    );
  }

  Widget _buildTabContent(FamilyState state, bool isDark) {
    return AnimatedBuilder(
      animation: _tabController,
      builder: (context, _) {
        if (_tabController.index == 0) {
          return _buildMembersList(state, isDark);
        } else {
          return _buildInvitesList(state, isDark);
        }
      },
    );
  }

  Widget _buildMembersList(FamilyState state, bool isDark) {
    if (state.isMembersLoading && state.members.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, __) => const FamilyMemberCardSkeleton(),
            childCount: 3,
          ),
        ),
      );
    }

    if (state.members.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Text(
            'No members found',
            style: SpendexTheme.bodyMedium.copyWith(
              color: isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final member = state.members[index];
            final isCurrentUser = member.id == state.currentUserMember?.id;

            return FamilyMemberCard(
              member: member,
              isCurrentUser: isCurrentUser,
              canManage: state.canManageMembers && !member.isOwner && !isCurrentUser,
              onEditRole: () => _showEditRoleSheet(context, member, isDark),
              onRemove: () => _showRemoveMemberDialog(context, member, isDark),
            );
          },
          childCount: state.members.length,
        ),
      ),
    );
  }

  Widget _buildInvitesList(FamilyState state, bool isDark) {
    if (state.isInvitesLoading && state.pendingInvites.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (_, __) => const PendingInviteCardSkeleton(),
            childCount: 2,
          ),
        ),
      );
    }

    if (state.pendingInvites.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Iconsax.send_2,
                size: 48,
                color: isDark ? SpendexColors.darkTextTertiary : SpendexColors.lightTextTertiary,
              ),
              const SizedBox(height: 16),
              Text(
                'No pending invites',
                style: SpendexTheme.bodyMedium.copyWith(
                  color:
                      isDark ? SpendexColors.darkTextSecondary : SpendexColors.lightTextSecondary,
                ),
              ),
              if (state.canManageMembers) ...[
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () => _showInviteMemberSheet(context),
                  icon: const Icon(Iconsax.user_add),
                  label: const Text('Invite Someone'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final invite = state.pendingInvites[index];
            return PendingInviteCard(
              invite: invite,
              canManage: state.canManageMembers,
              onCancel: () => _cancelInvite(invite.id),
            );
          },
          childCount: state.pendingInvites.length,
        ),
      ),
    );
  }

  void _showCreateFamilyDialog(BuildContext context, bool isDark) {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Family'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Family Name',
            hintText: 'e.g., The Smiths',
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          Consumer(
            builder: (ctx, ref, _) {
              final isCreating = ref.watch(familyStateProvider).isCreating;
              return ElevatedButton(
                onPressed: isCreating
                    ? null
                    : () async {
                        final name = nameController.text.trim();
                        if (name.isEmpty) {
                          return;
                        }
                        final request = CreateFamilyRequest(name: name);
                        final result =
                            await ref.read(familyStateProvider.notifier).createFamily(request);
                        if (result != null && ctx.mounted) {
                          Navigator.pop(ctx);
                        }
                      },
                child: isCreating
                    ? const SizedBox(
                        width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2),)
                    : const Text('Create'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showJoinFamilyDialog(BuildContext context, bool isDark) {
    final tokenController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Join Family'),
        content: TextField(
          controller: tokenController,
          decoration: const InputDecoration(
            labelText: 'Invite Code',
            hintText: 'Paste your invite code',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          Consumer(
            builder: (ctx, ref, _) {
              final isAccepting = ref.watch(familyStateProvider).isAcceptingInvite;
              return ElevatedButton(
                onPressed: isAccepting
                    ? null
                    : () async {
                        final token = tokenController.text.trim();
                        if (token.isEmpty) {
                          return;
                        }
                        final result =
                            await ref.read(familyStateProvider.notifier).acceptInvite(token);
                        if (result != null && ctx.mounted) {
                          Navigator.pop(ctx);
                        }
                      },
                child: isAccepting
                    ? const SizedBox(
                        width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2),)
                    : const Text('Join'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showInviteMemberSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => InviteMemberSheet(
        onInvite: (email, role) async {
          final request = SendInviteRequest(email: email, role: role.value);
          await ref.read(familyStateProvider.notifier).sendInvite(request);
        },
      ),
    );
  }

  void _showEditRoleSheet(BuildContext context, FamilyMemberModel member, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => MemberRoleSelector(
        currentRole: member.role,
        onRoleSelected: (role) async {
          Navigator.pop(ctx);
          await ref.read(familyStateProvider.notifier).updateMemberRole(member.id, role);
        },
      ),
    );
  }

  void _showRemoveMemberDialog(BuildContext context, FamilyMemberModel member, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text('Are you sure you want to remove ${member.name} from the family?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          Consumer(
            builder: (ctx, ref, _) {
              final isRemoving = ref.watch(familyStateProvider).isRemovingMember;
              return ElevatedButton(
                onPressed: isRemoving
                    ? null
                    : () async {
                        final success =
                            await ref.read(familyStateProvider.notifier).removeMember(member.id);
                        if (success && ctx.mounted) {
                          Navigator.pop(ctx);
                        }
                      },
                style: ElevatedButton.styleFrom(backgroundColor: SpendexColors.expense),
                child: isRemoving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),)
                    : const Text('Remove'),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showFamilySettingsSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? SpendexColors.darkCard : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? SpendexColors.darkBorder : SpendexColors.lightBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Iconsax.user_tick),
              title: const Text('Transfer Ownership'),
              onTap: () {
                Navigator.pop(ctx);
                _showTransferOwnershipDialog(context, isDark);
              },
            ),
            ListTile(
              leading: const Icon(Iconsax.logout, color: SpendexColors.expense),
              title: const Text('Leave Family', style: TextStyle(color: SpendexColors.expense)),
              onTap: () {
                Navigator.pop(ctx);
                _showLeaveFamilyDialog(context, isDark);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showTransferOwnershipDialog(BuildContext context, bool isDark) {
    final state = ref.read(familyStateProvider);
    final otherMembers = state.otherMembers;

    if (otherMembers.isEmpty) {
      _showErrorSnackBar('No other members to transfer ownership to');
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Transfer Ownership'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select the new owner:'),
            const SizedBox(height: 16),
            ...otherMembers.map(
              (member) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: SpendexColors.primary,
                  child: Text(member.name[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),),
                ),
                title: Text(member.name),
                subtitle: Text(member.email),
                onTap: () async {
                  Navigator.pop(ctx);
                  await ref.read(familyStateProvider.notifier).transferOwnership(member.id);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showLeaveFamilyDialog(BuildContext context, bool isDark) {
    final state = ref.read(familyStateProvider);

    if (state.isOwner) {
      _showErrorSnackBar('Transfer ownership before leaving the family');
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave Family'),
        content: const Text(
            'Are you sure you want to leave this family? You will lose access to shared data.',),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          Consumer(
            builder: (ctx, ref, _) {
              final isLeaving = ref.watch(familyStateProvider).isLeavingFamily;
              return ElevatedButton(
                onPressed: isLeaving
                    ? null
                    : () async {
                        final success = await ref.read(familyStateProvider.notifier).leaveFamily();
                        if (success && ctx.mounted) {
                          Navigator.pop(ctx);
                        }
                      },
                style: ElevatedButton.styleFrom(backgroundColor: SpendexColors.expense),
                child: isLeaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),)
                    : const Text('Leave'),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _cancelInvite(String inviteId) async {
    await ref.read(familyStateProvider.notifier).cancelInvite(inviteId);
  }
}
