import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/mascot/sila_mascot.dart';
import '../../../core/validation/form_validators.dart';
import '../../../core/widgets/sila_page_backdrop.dart';
import '../../../l10n/app_localizations.dart';
import '../../authentication/screens/family_choice_screen.dart';
import '../../mascot/widgets/sila_companion_callout.dart';

class FamilyManagementScreen extends StatefulWidget {
  const FamilyManagementScreen({super.key, this.developerPreview = false});

  final bool developerPreview;

  @override
  State<FamilyManagementScreen> createState() => _FamilyManagementScreenState();
}

class _FamilyManagementScreenState extends State<FamilyManagementScreen> {
  bool _isUpdating = false;
  String? _busyMemberId;

  void _showReadOnlyNotice() {
    final strings = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(strings.developerPreviewReadOnly)));
  }

  Future<void> _copyInviteCode(String inviteCode) async {
    await Clipboard.setData(ClipboardData(text: inviteCode));

    if (!mounted) return;

    final strings = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(strings.familyInviteCodeCopied)));
  }

  Future<void> _editFamily({
    required String familyId,
    required String currentName,
    required String currentDescription,
  }) async {
    if (widget.developerPreview) {
      _showReadOnlyNotice();
      return;
    }

    final strings = AppLocalizations.of(context)!;
    final formKey = GlobalKey<FormState>();
    var editedName = currentName;
    var editedDescription = currentDescription;

    final edits = await showDialog<_FamilyEdits>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(strings.editFamilyDetails),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: currentName,
                    onChanged: (value) => editedName = value,
                    maxLength: 40,
                    textCapitalization: TextCapitalization.words,
                    validator: LocalizedFormValidators(
                      strings,
                    ).validateFamilyName,
                    decoration: InputDecoration(labelText: strings.familyName),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: currentDescription,
                    onChanged: (value) => editedDescription = value,
                    maxLength: 120,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: strings.familyDescriptionOptional,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(strings.cancel),
            ),
            FilledButton(
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) return;

                Navigator.pop(
                  dialogContext,
                  _FamilyEdits(
                    name: editedName.trim(),
                    description: editedDescription.trim(),
                  ),
                );
              },
              child: Text(strings.saveFamily),
            ),
          ],
        );
      },
    );

    if (edits == null) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('families')
          .doc(familyId)
          .update({
            'name': edits.name,
            'description': edits.description,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.familyUpdated)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.couldNotUpdateFamily)));
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _toggleAdmin({
    required String familyId,
    required _FamilyMemberInfo member,
    required bool makeAdmin,
  }) async {
    if (widget.developerPreview) {
      _showReadOnlyNotice();
      return;
    }

    final strings = AppLocalizations.of(context)!;
    setState(() {
      _busyMemberId = member.id;
    });

    try {
      await FirebaseFirestore.instance
          .collection('families')
          .doc(familyId)
          .update({
            'rewardApproverIds': makeAdmin
                ? FieldValue.arrayUnion([member.id])
                : FieldValue.arrayRemove([member.id]),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.adminRoleUpdated)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.couldNotUpdateAdminRole)));
    } finally {
      if (mounted) {
        setState(() {
          _busyMemberId = null;
        });
      }
    }
  }

  Future<void> _transferOwnership({
    required String familyId,
    required _FamilyMemberInfo member,
  }) async {
    if (widget.developerPreview) {
      _showReadOnlyNotice();
      return;
    }

    final strings = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.transferOwnershipQuestion(member.name)),
        content: Text(strings.transferOwnershipWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(strings.transferOwnership),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _busyMemberId = member.id;
    });

    try {
      await FirebaseFirestore.instance
          .collection('families')
          .doc(familyId)
          .update({
            'ownerId': member.id,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.ownershipTransferred)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.couldNotTransferOwnership)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _busyMemberId = null;
        });
      }
    }
  }

  Future<void> _removeMember({
    required String familyId,
    required _FamilyMemberInfo member,
  }) async {
    if (widget.developerPreview) {
      _showReadOnlyNotice();
      return;
    }

    final strings = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.removeMemberQuestion(member.name)),
        content: Text(strings.removeMemberWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(strings.removeMember),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _busyMemberId = member.id;
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();
      batch.update(firestore.collection('families').doc(familyId), {
        'members': FieldValue.arrayRemove([member.id]),
        'rewardApproverIds': FieldValue.arrayRemove([member.id]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      batch.set(firestore.collection('users').doc(member.id), {
        'familyId': null,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await batch.commit();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.familyMemberRemoved)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.couldNotRemoveMember)));
    } finally {
      if (mounted) {
        setState(() {
          _busyMemberId = null;
        });
      }
    }
  }

  Future<void> _leaveFamily({
    required String familyId,
    required String userId,
    required bool isOwner,
  }) async {
    final strings = AppLocalizations.of(context)!;

    if (isOwner) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(strings.ownerCannotLeave),
          content: Text(strings.ownerCannotLeaveDescription),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(strings.gotIt),
            ),
          ],
        ),
      );
      return;
    }

    if (widget.developerPreview) {
      _showReadOnlyNotice();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.leaveFamilyQuestion),
        content: Text(strings.leaveFamilyWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(strings.leaveFamily),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();
      batch.update(firestore.collection('families').doc(familyId), {
        'members': FieldValue.arrayRemove([userId]),
        'rewardApproverIds': FieldValue.arrayRemove([userId]),
      });
      batch.set(firestore.collection('users').doc(userId), {
        'familyId': null,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      await batch.commit();

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.leftFamilySuccessfully)));
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(strings.couldNotLeaveFamily)));
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    if (widget.developerPreview) {
      return Scaffold(
        appBar: AppBar(title: Text(strings.familyManagement)),
        body: SilaPageBackdrop(
          child: _buildContent(
            familyId: 'DEV123',
            currentUserId: 'developer',
            familyName: strings.developerFamilyName,
            description: strings.developerFamilyDescription,
            inviteCode: 'DEV123',
            ownerId: 'developer',
            adminIds: const {'member-2'},
            members: [
              _FamilyMemberInfo(
                id: 'developer',
                name: strings.silaDeveloper,
                email: 'preview@sila.local',
              ),
              _FamilyMemberInfo(
                id: 'member-2',
                name: strings.developerFamilyMemberName,
                email: 'member@sila.local',
              ),
              _FamilyMemberInfo(
                id: 'member-3',
                name: strings.developerFamilyMemberTwoName,
                email: 'family@sila.local',
              ),
            ],
          ),
        ),
      );
    }

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(strings.familyManagement)),
        body: Center(child: Text(strings.noUserSignedIn)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(strings.familyManagement)),
      body: SilaPageBackdrop(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (userSnapshot.hasError) {
              return _FamilyLoadError(message: strings.familyLoadError);
            }

            final familyId = userSnapshot.data?.data()?['familyId'] as String?;

            if (familyId == null || familyId.isEmpty) {
              return _NoFamilyState(
                onSetupFamily: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const FamilyChoiceScreen(),
                    ),
                  );
                },
              );
            }

            return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('families')
                  .doc(familyId)
                  .snapshots(),
              builder: (context, familySnapshot) {
                if (familySnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (familySnapshot.hasError ||
                    familySnapshot.data?.exists != true) {
                  return _FamilyLoadError(message: strings.familyLoadError);
                }

                final familyData = familySnapshot.data!.data()!;
                final memberIds = Set<String>.from(
                  (familyData['members'] as List<dynamic>? ?? const []).map(
                    (id) => id.toString(),
                  ),
                );
                final ownerId = familyData['ownerId']?.toString() ?? '';
                final adminIds = Set<String>.from(
                  (familyData['rewardApproverIds'] as List<dynamic>? ??
                          const [])
                      .map((id) => id.toString()),
                );

                return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('familyId', isEqualTo: familyId)
                      .snapshots(),
                  builder: (context, membersSnapshot) {
                    if (membersSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (membersSnapshot.hasError) {
                      return _FamilyLoadError(
                        message: strings.familyMembersLoadError,
                      );
                    }

                    final members = membersSnapshot.data!.docs
                        .where((document) => memberIds.contains(document.id))
                        .map((document) {
                          final data = document.data();
                          final email = data['email']?.toString().trim() ?? '';
                          final rawName = data['name']?.toString().trim() ?? '';

                          return _FamilyMemberInfo(
                            id: document.id,
                            name: rawName.isNotEmpty
                                ? rawName
                                : email.isNotEmpty
                                ? email
                                : strings.familyMemberFallback,
                            email: email,
                          );
                        })
                        .toList();

                    for (final memberId in memberIds) {
                      if (members.every((member) => member.id != memberId)) {
                        members.add(
                          _FamilyMemberInfo(
                            id: memberId,
                            name: strings.familyMemberFallback,
                            email: '',
                          ),
                        );
                      }
                    }

                    members.sort((a, b) {
                      if (a.id == ownerId) return -1;
                      if (b.id == ownerId) return 1;
                      if (a.id == user.uid) return -1;
                      if (b.id == user.uid) return 1;
                      return a.name.toLowerCase().compareTo(
                        b.name.toLowerCase(),
                      );
                    });

                    return _buildContent(
                      familyId: familyId,
                      currentUserId: user.uid,
                      familyName:
                          familyData['name']?.toString() ?? strings.yourFamily,
                      description:
                          familyData['description']?.toString().trim() ?? '',
                      inviteCode:
                          familyData['inviteCode']?.toString() ?? familyId,
                      ownerId: ownerId,
                      adminIds: adminIds,
                      members: members,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent({
    required String familyId,
    required String currentUserId,
    required String familyName,
    required String description,
    required String inviteCode,
    required String ownerId,
    required Set<String> adminIds,
    required List<_FamilyMemberInfo> members,
  }) {
    final strings = AppLocalizations.of(context)!;
    final isOwner = currentUserId == ownerId;
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 36),
      children: [
        Text(
          strings.familyManagementDescription,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 14),
        Card(
          color: colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.family_restroom_rounded,
                      size: 38,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        familyName,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                    if (isOwner)
                      IconButton.filledTonal(
                        tooltip: strings.editFamily,
                        onPressed: _isUpdating
                            ? null
                            : () => _editFamily(
                                familyId: familyId,
                                currentName: familyName,
                                currentDescription: description,
                              ),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(description),
                ],
                const SizedBox(height: 20),
                Text(
                  strings.inviteRelatives,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(strings.familyInviteDescription),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        inviteCode,
                        textDirection: TextDirection.ltr,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 3,
                            ),
                      ),
                    ),
                    IconButton.filled(
                      tooltip: strings.copyInviteCode,
                      onPressed: () => _copyInviteCode(inviteCode),
                      icon: const Icon(Icons.copy_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        _RoleGuideCard(),
        const SizedBox(height: 24),
        Text(
          strings.familyMembersTitle,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(strings.familyMembersDescription),
        const SizedBox(height: 12),
        ...members.map((member) {
          final isMemberOwner = member.id == ownerId;
          final isAdmin = adminIds.contains(member.id);
          final isCurrentUser = member.id == currentUserId;
          final isBusy = _busyMemberId == member.id;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                contentPadding: const EdgeInsetsDirectional.fromSTEB(
                  16,
                  8,
                  10,
                  8,
                ),
                leading: CircleAvatar(
                  child: Text(member.name.characters.first.toUpperCase()),
                ),
                title: Text(
                  isCurrentUser
                      ? strings.familyMemberYou(member.name)
                      : member.name,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (member.email.isNotEmpty) Text(member.email),
                    const SizedBox(height: 4),
                    _RoleBadge(
                      label: isMemberOwner
                          ? strings.familyRoleOwner
                          : isAdmin
                          ? strings.familyRoleAdmin
                          : strings.familyRoleMember,
                      emphasized: isMemberOwner || isAdmin,
                    ),
                  ],
                ),
                trailing: isBusy
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : isOwner && !isCurrentUser
                    ? PopupMenuButton<_MemberAction>(
                        tooltip: strings.memberActions,
                        onSelected: (action) {
                          switch (action) {
                            case _MemberAction.toggleAdmin:
                              _toggleAdmin(
                                familyId: familyId,
                                member: member,
                                makeAdmin: !isAdmin,
                              );
                            case _MemberAction.transferOwnership:
                              _transferOwnership(
                                familyId: familyId,
                                member: member,
                              );
                            case _MemberAction.remove:
                              _removeMember(familyId: familyId, member: member);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: _MemberAction.toggleAdmin,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                isAdmin
                                    ? Icons.remove_moderator_outlined
                                    : Icons.admin_panel_settings_outlined,
                              ),
                              title: Text(
                                isAdmin
                                    ? strings.removeAdmin
                                    : strings.makeAdmin,
                              ),
                            ),
                          ),
                          PopupMenuItem(
                            value: _MemberAction.transferOwnership,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.swap_horiz_rounded),
                              title: Text(strings.transferOwnership),
                            ),
                          ),
                          PopupMenuItem(
                            value: _MemberAction.remove,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                Icons.person_remove_outlined,
                                color: colorScheme.error,
                              ),
                              title: Text(
                                strings.removeMember,
                                style: TextStyle(color: colorScheme.error),
                              ),
                            ),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
          );
        }),
        const SizedBox(height: 18),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.error,
            side: BorderSide(color: colorScheme.error),
          ),
          onPressed: _isUpdating
              ? null
              : () => _leaveFamily(
                  familyId: familyId,
                  userId: currentUserId,
                  isOwner: isOwner,
                ),
          icon: const Icon(Icons.exit_to_app_rounded),
          label: Text(
            isOwner ? strings.transferBeforeLeaving : strings.leaveFamily,
          ),
        ),
        if (_isUpdating) ...[
          const SizedBox(height: 16),
          const LinearProgressIndicator(),
        ],
      ],
    );
  }
}

class _RoleGuideCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.familyRoles,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            _RoleExplanation(
              icon: Icons.shield_rounded,
              title: strings.familyRoleOwner,
              description: strings.familyOwnerDescription,
            ),
            const SizedBox(height: 10),
            _RoleExplanation(
              icon: Icons.admin_panel_settings_rounded,
              title: strings.familyRoleAdmin,
              description: strings.familyAdminDescription,
            ),
            const SizedBox(height: 10),
            _RoleExplanation(
              icon: Icons.person_rounded,
              title: strings.familyRoleMember,
              description: strings.familyMemberDescription,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleExplanation extends StatelessWidget {
  const _RoleExplanation({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              Text(description),
            ],
          ),
        ),
      ],
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.label, required this.emphasized});

  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: emphasized
            ? colorScheme.primaryContainer
            : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _FamilyLoadError extends StatelessWidget {
  const _FamilyLoadError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: SilaCompanionCallout(
            key: const ValueKey('family-management-sila-error'),
            userId: FirebaseAuth.instance.currentUser?.uid,
            title: strings.familyManagement,
            message: message,
            pose: SilaMascotPose.oops,
          ),
        ),
      ),
    );
  }
}

class _NoFamilyState extends StatelessWidget {
  const _NoFamilyState({required this.onSetupFamily});

  final VoidCallback onSetupFamily;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: SilaCompanionCallout(
            key: const ValueKey('family-management-sila-empty'),
            userId: FirebaseAuth.instance.currentUser?.uid,
            title: strings.youHaveNotJoinedFamily,
            message: strings.familyManagementDescription,
            pose: SilaMascotPose.welcome,
            action: FilledButton.icon(
              onPressed: onSetupFamily,
              icon: const Icon(Icons.family_restroom_rounded),
              label: Text(strings.createOrJoinFamilyAction),
            ),
          ),
        ),
      ),
    );
  }
}

class _FamilyMemberInfo {
  const _FamilyMemberInfo({
    required this.id,
    required this.name,
    required this.email,
  });

  final String id;
  final String name;
  final String email;
}

class _FamilyEdits {
  const _FamilyEdits({required this.name, required this.description});

  final String name;
  final String description;
}

enum _MemberAction { toggleAdmin, transferOwnership, remove }
