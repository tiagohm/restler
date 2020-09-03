import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:restler/data/entities/certificate_entity.dart';
import 'package:restler/mdi.dart';
import 'package:restler/ui/widgets/dot_menu_button.dart';
import 'package:restler/ui/widgets/state_mixin.dart';
import 'package:restler/ui/widgets/label.dart';

enum CertificateCardAction { edit, duplicate, move, copy, delete }

class CertificateCard extends StatefulWidget {
  final CertificateEntity certificate;
  final ValueChanged<bool> onEnabled;
  final ValueChanged<CertificateCardAction> onActionSelected;

  const CertificateCard({
    Key key,
    this.certificate,
    this.onEnabled,
    this.onActionSelected,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CertificateCardState();
  }
}

class _CertificateCardState extends State<CertificateCard>
    with StateMixin<CertificateCard> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListTile(
        // Icon.
        leading: Container(
          width: 42,
          height: 42,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).primaryColor,
          ),
          child: const Center(
            child: Icon(
              Mdi.certificate,
              color: Colors.white,
            ),
          ),
        ),
        // Host.
        title: Row(
          children: [
            Text(widget.certificate.host ?? ''),
            if (widget.certificate.port != null) const Text(':'),
            Text(widget.certificate.port?.toString() ?? ''),
          ],
        ),
        // Value.
        subtitle: Row(
          children: <Widget>[
            // CRT.
            if (widget.certificate.crt != null &&
                widget.certificate.crt.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Label(
                  text: 'CRT',
                  color: Colors.green,
                ),
              ),
            // KEY.
            if (widget.certificate.key != null &&
                widget.certificate.key.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Label(
                  text: 'KEY',
                  color: Colors.blue,
                ),
              ),
            // PASSPHRASE.
            if (widget.certificate.passphrase != null &&
                widget.certificate.passphrase.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Label(
                  text: i18n.passphrase.toUpperCase(),
                  color: Colors.red,
                ),
              ),
          ],
        ),
        trailing: Flex(
          direction: Axis.horizontal,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Enable.
            Checkbox(
              value: widget.certificate.enabled,
              onChanged: widget.onEnabled,
            ),
            // Options.
            DotMenuButton<CertificateCardAction>(
              items: const [
                CertificateCardAction.edit,
                CertificateCardAction.duplicate,
                CertificateCardAction.move,
                CertificateCardAction.copy,
                null, // Divider.
                CertificateCardAction.delete,
              ],
              itemBuilder: (context, i, item) {
                return ListTile(
                  leading: Icon(_obtainCertificateCardActionIcon(item)),
                  title: Text(_obtainCertificateCardActionName(item)),
                );
              },
              onSelected: widget.onActionSelected,
            ),
          ],
        ),
      ),
    );
  }

  IconData _obtainCertificateCardActionIcon(CertificateCardAction action) {
    switch (action) {
      case CertificateCardAction.edit:
        return Icons.edit;
      case CertificateCardAction.duplicate:
        return Mdi.duplicate;
      case CertificateCardAction.move:
        return Mdi.folderMove;
      case CertificateCardAction.copy:
        return Icons.content_copy;
      case CertificateCardAction.delete:
        return Icons.delete;
    }

    return null;
  }

  String _obtainCertificateCardActionName(CertificateCardAction action) {
    switch (action) {
      case CertificateCardAction.edit:
        return i18n.edit;
      case CertificateCardAction.duplicate:
        return i18n.duplicate;
      case CertificateCardAction.move:
        return i18n.move;
      case CertificateCardAction.copy:
        return i18n.copy;
      case CertificateCardAction.delete:
        return i18n.delete;
    }

    return null;
  }
}
