import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/contact_model.dart';

class ContactCard extends ConsumerWidget {
  final ContactModel contact;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showLastInteraction;

  const ContactCard({
    super.key,
    required this.contact,
    this.onTap,
    this.onLongPress,
    this.showLastInteraction = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              _buildAvatar(context),
              const SizedBox(width: 16),
              
              // Contact info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and birthday indicator
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            contact.displayName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (contact.hasBirthdayToday)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.cake,
                                  size: 14,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Hoje',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Contact details
                    if (contact.hasPhone || contact.hasEmail)
                      Text(
                        _buildContactDetails(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    
                    // Tags
                    if (contact.hasTags) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: contact.tags.take(3).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tag,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSecondaryContainer,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    
                    // Last interaction info
                    if (showLastInteraction) ...[
                      const SizedBox(height: 8),
                      _buildLastInteractionInfo(context),
                    ],
                  ],
                ),
              ),
              
              // Action buttons
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CircleAvatar(
      radius: 24,
      backgroundColor: contact.hasPhoto ? null : colorScheme.primaryContainer,
      backgroundImage: contact.hasPhoto 
          ? NetworkImage(contact.photoPath!) 
          : null,
      child: contact.hasPhoto 
          ? null 
          : Text(
              contact.initials,
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  String _buildContactDetails() {
    final details = <String>[];
    
    if (contact.hasPhone) {
      details.add(contact.phone!);
    }
    
    if (contact.hasEmail) {
      details.add(contact.email!);
    }
    
    return details.join(' • ');
  }

  Widget _buildLastInteractionInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // This would be populated from interaction data
    // For now, showing placeholder
    return Row(
      children: [
        Icon(
          Icons.schedule,
          size: 14,
          color: colorScheme.outline,
        ),
        const SizedBox(width: 4),
        Text(
          'Última interação: há 5 dias',
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.outline,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (contact.hasPhone)
          IconButton(
            icon: const Icon(Icons.phone),
            iconSize: 20,
            onPressed: () {
              // TODO: Implement phone call
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ligando para ${contact.name}...'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Ligar',
          ),
        
        if (contact.hasPhone)
          IconButton(
            icon: const Icon(Icons.message),
            iconSize: 20,
            onPressed: () {
              // TODO: Implement WhatsApp/SMS
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Enviando mensagem para ${contact.name}...'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            tooltip: 'Mensagem',
          ),
      ],
    );
  }
}