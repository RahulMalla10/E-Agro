import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:krishi_smart/core/l10n/locale_provider.dart';
import 'package:krishi_smart/core/widgets/product_image.dart';
import 'package:krishi_smart/core/models/user_role.dart';
import 'package:krishi_smart/core/providers/app_providers.dart';
import 'package:krishi_smart/features/home/data/product_models.dart';
import 'package:krishi_smart/core/widgets/nepali_roman_text_field.dart';
import 'package:krishi_smart/features/home/presentation/home_screen.dart';

class SellerUploadScreen extends ConsumerStatefulWidget {
  const SellerUploadScreen({super.key});

  @override
  ConsumerState<SellerUploadScreen> createState() => _SellerUploadScreenState();
}

class _SellerUploadScreenState extends ConsumerState<SellerUploadScreen> {
  final _nameEn = TextEditingController();
  String _nameNe = '';
  final _stock = TextEditingController();
  final _price = TextEditingController();
  final _images = <File>[];
  ProductCategory _category = ProductCategory.vegetables;
  String _unit = 'kg';
  bool _saving = false;

  @override
  void dispose() {
    _nameEn.dispose();
    _stock.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_images.length >= 5) return;
    await ref.read(permissionServiceProvider).requestPhotos();
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(maxWidth: 1200);
    if (files.isEmpty) return;
    setState(() {
      for (final f in files) {
        if (_images.length < 5) _images.add(File(f.path));
      }
    });
  }

  Future<void> _save() async {
    final s = ref.read(stringsProvider);
    if (_nameEn.text.trim().isEmpty || _nameNe.trim().isEmpty) {
      _snack(s.enterBothNames);
      return;
    }
    if (_images.length < 2) {
      _snack(s.photosRequired);
      return;
    }
    final stock = double.tryParse(_stock.text);
    final price = double.tryParse(_price.text);
    if (stock == null || stock <= 0 || price == null || price <= 0) {
      _snack(s.stockPriceRequired);
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(productRepositoryProvider).createListing(
            name: _nameEn.text,
            nameNe: _nameNe,
            category: _category,
            images: _images,
            stockQuantity: stock,
            stockUnit: _unit,
            priceNpr: price,
            sellerId: 'local-seller',
          );
      ref.invalidate(productsProvider);
      if (mounted) context.pop(true);
    } catch (e) {
      _snack('$e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(stringsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(s.listProduct)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(s.photosHint, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          SizedBox(
            height: 88,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ..._images.map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: 96,
                      child: ProductImage(
                        imagePath: f.path,
                        aspectRatio: 1,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                if (_images.length < 5)
                  InkWell(
                    onTap: _pickImages,
                    child: Container(
                      width: 88,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).dividerColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add_a_photo_outlined),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameEn,
            decoration: InputDecoration(labelText: s.productNameEn),
          ),
          const SizedBox(height: 12),
          NepaliRomanTextField(
            label: s.productNameNeRequired,
            hint: s.productNameNeRomanHint,
            onNepaliChanged: (v) => _nameNe = v,
          ),
          const SizedBox(height: 16),
          Text(s.category, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ProductCategory.values.map((c) {
              return ChoiceChip(
                label: Text(s.categoryLabel(c.dbValue)),
                selected: _category == c,
                onSelected: (_) => setState(() => _category = c),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _stock,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                  decoration: InputDecoration(labelText: s.stockAmount),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _unit,
                  decoration: InputDecoration(labelText: s.unit),
                  items: StockUnit.units
                      .map(
                        (u) => DropdownMenuItem(
                          value: u.id,
                          child: Text(s.isNepali ? u.labelNe : u.labelEn),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _unit = v ?? 'kg'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _price,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
            decoration: InputDecoration(labelText: s.pricePerUnit),
          ),
          const SizedBox(height: 28),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(s.publishListing),
          ),
        ],
      ),
    );
  }
}
