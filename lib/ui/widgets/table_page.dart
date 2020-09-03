import 'package:flutter/material.dart';

// ignore_for_file: prefer_const_constructors

class TablePage<T> extends StatelessWidget {
  final Map<int, FractionColumnWidth> columnWidths;
  final List<T> items;
  final Color headerColor;
  final Color evenColor;
  final Color oddColor;
  final List<Widget> Function(BuildContext context) headerBuilder;
  final List<Widget> Function(BuildContext context, int index, T item)
      itemBuilder;

  const TablePage({
    Key key,
    @required this.columnWidths,
    @required this.items,
    this.headerColor,
    @required this.evenColor,
    @required this.oddColor,
    this.headerBuilder,
    @required this.itemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      children: [
        Table(
          columnWidths: columnWidths,
          children: [
            // Header.
            TableRow(
              children: [
                if (headerBuilder != null)
                  for (final header in headerBuilder(context))
                    TableCell(
                      child: Container(
                        color: headerColor ?? oddColor,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: header,
                        ),
                      ),
                    ),
              ],
            ),
            // Data.
            for (var i = 0; i < items.length; i++)
              TableRow(
                children: [
                  for (final item in itemBuilder(context, i, items[i]))
                    TableCell(
                      child: Container(
                        color: i.isEven ? evenColor : oddColor,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: item,
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}
