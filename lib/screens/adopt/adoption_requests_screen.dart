import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/adoption_request_service.dart';

class AdoptionRequestsScreen extends StatelessWidget {
  const AdoptionRequestsScreen({super.key});

  static const _green = Color(0xFF1D9E75);
  static const _greenLight = Color(0xFFE1F5EE);
  static const _textMain = Color(0xFF0A2E24);
  static const _textMuted = Color(0xFF6B8F80);

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4FAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Adoption requests',
            style: GoogleFonts.nunito(
                fontSize: 18, fontWeight: FontWeight.w800, color: _textMain)),
        leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_rounded, color: Color(0xFF0A2E24)),
            onPressed: () => Navigator.pop(context)),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: const Color(0xFFE5F0EA))),
      ),
      body: StreamBuilder<List<AdoptionRequest>>(
        stream: AdoptionRequestService.incomingRequestsStream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: _green));
          }

          final requests = snap.data ?? [];

          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                          color: _greenLight, shape: BoxShape.circle),
                      child: const Icon(Icons.inbox_outlined,
                          size: 40, color: _green)),
                  const SizedBox(height: 16),
                  Text('No pending requests',
                      style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: _textMain)),
                  const SizedBox(height: 6),
                  Text('Adoption requests will appear here',
                      style:
                          GoogleFonts.nunito(fontSize: 13, color: _textMuted)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            itemCount: requests.length,
            itemBuilder: (_, i) {
              final req = requests[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5F0EA))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                            color: _greenLight, shape: BoxShape.circle),
                        child: Center(
                            child: Text(
                                req.requesterName.isNotEmpty
                                    ? req.requesterName[0].toUpperCase()
                                    : '?',
                                style: GoogleFonts.nunito(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: _green))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(req.requesterName,
                                style: GoogleFonts.nunito(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: _textMain)),
                            Text('Wants to adopt ${req.petName}',
                                style: GoogleFonts.nunito(
                                    fontSize: 12, color: _textMuted)),
                          ],
                        ),
                      ),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(20)),
                          child: Text('Pending',
                              style: GoogleFonts.nunito(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFD97706)))),
                    ]),

                    const SizedBox(height: 14),
                    Container(height: 0.5, color: const Color(0xFFE5F0EA)),
                    const SizedBox(height: 12),

                    // Contact
                    if (req.requesterContact.isNotEmpty) ...[
                      Row(children: [
                        const Icon(Icons.phone_outlined,
                            size: 16, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 6),
                        Text(req.requesterContact,
                            style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _textMain)),
                      ]),
                      const SizedBox(height: 6),
                    ],

                    // Date
                    Row(children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: 14, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 6),
                      Text(_formatDate(req.createdAt),
                          style: GoogleFonts.nunito(
                              fontSize: 12, color: _textMuted)),
                    ]),

                    const SizedBox(height: 14),

                    // Accept / Reject buttons
                    Row(children: [
                      Expanded(
                        child: SizedBox(
                          height: 42,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await AdoptionRequestService.acceptRequest(
                                  req.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                      'Accepted! ${req.requesterName} can adopt ${req.petName} 🐾',
                                      style: GoogleFonts.nunito(
                                          fontWeight: FontWeight.w600)),
                                  backgroundColor: _green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  margin: const EdgeInsets.all(16),
                                ));
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: _green,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            icon: const Icon(Icons.check_circle_outline_rounded,
                                size: 18),
                            label: Text('Accept',
                                style: GoogleFonts.nunito(
                                    fontSize: 13, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 42,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await AdoptionRequestService.rejectRequest(
                                  req.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text('Request rejected',
                                      style: GoogleFonts.nunito(
                                          fontWeight: FontWeight.w600)),
                                  backgroundColor: const Color(0xFFDC2626),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  margin: const EdgeInsets.all(16),
                                ));
                              }
                            },
                            style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFDC2626),
                                side:
                                    const BorderSide(color: Color(0xFFDC2626)),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10))),
                            icon: const Icon(Icons.cancel_outlined, size: 18),
                            label: Text('Reject',
                                style: GoogleFonts.nunito(
                                    fontSize: 13, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ),
                    ]),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
