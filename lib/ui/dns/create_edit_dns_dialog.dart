import 'package:flutter/material.dart';
import 'package:restler/data/entities/dns_entity.dart';
import 'package:restler/helper.dart';
import 'package:restler/ui/constants.dart';
import 'package:restler/ui/widgets/data_dialog.dart';
import 'package:restler/ui/widgets/dialog_result.dart';
import 'package:restler/ui/widgets/state_mixin.dart';

class CreateEditDnsDialog extends StatefulWidget {
  final DnsEntity dns;

  const CreateEditDnsDialog(this.dns);

  static Future<DialogResult<DnsEntity>> show(
    BuildContext context,
    DnsEntity dns,
  ) async {
    return showDialog<DialogResult<DnsEntity>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CreateEditDnsDialog(dns),
    );
  }

  @override
  State<StatefulWidget> createState() {
    return CreateOrEditDnsState();
  }
}

class CreateOrEditDnsState extends State<CreateEditDnsDialog>
    with StateMixin<CreateEditDnsDialog> {
  TextEditingController _nameTextController;
  TextEditingController _addressTextController;
  TextEditingController _urlTextController;
  TextEditingController _portTextController;
  bool _https;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _nameTextController = TextEditingController(text: widget.dns?.name ?? '');
    _addressTextController =
        TextEditingController(text: widget.dns?.address ?? '');
    _urlTextController = TextEditingController(text: widget.dns?.url ?? '');
    _portTextController =
        TextEditingController(text: widget.dns?.port?.toString() ?? '53');
    _https = widget.dns?.https ?? false;

    super.initState();
  }

  @override
  void dispose() {
    _nameTextController.dispose();
    _addressTextController.dispose();
    _urlTextController.dispose();
    _portTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DataDialog<DnsEntity>(
      doneText: i18n.save,
      title: widget.dns == null ? i18n.newDns : i18n.editDns,
      onDone: _onSave,
      bodyBuilder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 4),
          child: Form(
            key: _formKey,
            child: ListBody(
              children: [
                // Name.
                TextFormField(
                  controller: _nameTextController,
                  validator: textIsRequired,
                  decoration: InputDecoration(labelText: i18n.name),
                  style: defaultInputTextStyle,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // HTTPS.
                    Checkbox(
                      value: _https,
                      onChanged: (enabled) {
                        setState(() {
                          _https = enabled;
                        });
                      },
                    ),
                    const Text(
                      'HTTPS',
                      style: defaultInputTextStyle,
                    ),
                  ],
                ),
                // Address.
                if (!_https)
                  TextFormField(
                    controller: _addressTextController,
                    validator: textIsRequired,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      hintText: '8.8.8.8',
                    ),
                    style: defaultInputTextStyle,
                  ),
                // Port.
                if (!_https)
                  TextFormField(
                    controller: _portTextController,
                    validator: textIsRequired,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Port',
                      hintText: '53',
                    ),
                    style: defaultInputTextStyle,
                  ),
                // Url.
                if (_https)
                  TextFormField(
                    controller: _urlTextController,
                    validator: textIsRequired,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      labelText: 'URL',
                      hintText: 'https://',
                    ),
                    style: defaultInputTextStyle,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<DnsEntity> _onSave() async {
    if (_formKey.currentState.validate()) {
      final name = _nameTextController.text.trim();
      final address = _addressTextController.text.trim();
      final url = _urlTextController.text.trim();
      final port = _portTextController.text.trim();

      // Create.
      if (widget.dns == null) {
        return DnsEntity(
          uid: generateUuid(),
          name: name,
          address: address,
          url: url,
          port: port.isEmpty ? 53 : int.tryParse(port) ?? 53,
          https: _https,
        );
      }
      // Edit.
      else {
        return DnsEntity(
          uid: widget.dns.uid,
          name: name,
          address: address,
          url: url,
          port: port.isEmpty ? 53 : int.tryParse(port) ?? 53,
          https: _https,
          enabled: widget.dns.enabled,
        );
      }
    } else {
      return null;
    }
  }
}
