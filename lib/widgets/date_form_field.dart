import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/utils/formatters.dart';

/// Kolom tanggal yang membuka `showDatePicker()`. Dibuat sebagai `FormField`
/// supaya ikut divalidasi oleh `FormState.validate()` dan pesan errornya
/// tampil di bawah kolom ini, sama seperti `TextFormField`.
class DateFormField extends FormField<DateTime> {
  DateFormField({
    super.key,
    required String label,
    required FormFieldValidator<DateTime> super.validator,
    ValueChanged<DateTime?>? onChanged,
    super.enabled,
    String disabledText = '-',
    DateTime? firstDate,
    DateTime? lastDate,
  }) : super(
         builder: (state) {
           final tanggal = state.value;

           Future<void> pilihTanggal() async {
             final sekarang = DateTime.now();
             final dipilih = await showDatePicker(
               context: state.context,
               initialDate: tanggal ?? sekarang,
               firstDate: firstDate ?? DateTime(2000),
               lastDate: lastDate ?? sekarang,
             );
             if (dipilih != null) {
               state.didChange(dipilih);
               onChanged?.call(dipilih);
             }
           }

           return InkWell(
             borderRadius: BorderRadius.circular(5.0),
             onTap: enabled ? pilihTanggal : null,
             child: InputDecorator(
               // isi selalu ada ("Pilih tanggal" atau tanggalnya), jadi label
               // dibiarkan melayang dan tidak menumpuk dengan isinya
               isEmpty: false,
               decoration: InputDecoration(
                 labelText: label,
                 errorText: state.errorText,
                 enabled: enabled,
                 suffixIcon: const Icon(Icons.calendar_today),
                 border: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(5.0),
                 ),
               ),
               child: Text(
                 !enabled
                     ? disabledText
                     : tanggal == null
                     ? 'Pilih tanggal'
                     : formatTanggal(tanggal),
               ),
             ),
           );
         },
       );
}
