import 'dart:collection';
import 'dart:io';

import 'package:image/image.dart' as img;

bool _nearWhite(int r, int g, int b, {int threshold = 18}) {
  return (255 - r) <= threshold && (255 - g) <= threshold && (255 - b) <= threshold;
}

void main(List<String> args) {
  final inputPath = args.isNotEmpty ? args[0] : 'assets/images/launcher_icon_source.png';
  final outputPath = args.length > 1 ? args[1] : 'assets/images/launcher_icon.png';

  final bytes = File(inputPath).readAsBytesSync();
  final image = img.decodeImage(bytes);
  if (image == null) {
    stderr.writeln('Could not decode: $inputPath');
    exitCode = 2;
    return;
  }

  // Ensure we have RGBA.
  final im = image.convert(numChannels: 4);
  final w = im.width;
  final h = im.height;

  // Flood-fill the *background white* that is connected to the outer edges,
  // so internal whites (logo text) are preserved.
  final visited = List<bool>.filled(w * h, false);
  final q = Queue<int>();

  void tryAdd(int x, int y) {
    if (x < 0 || y < 0 || x >= w || y >= h) return;
    final idx = y * w + x;
    if (visited[idx]) return;
    final p = im.getPixel(x, y);
    final r = p.r.toInt();
    final g = p.g.toInt();
    final b = p.b.toInt();
    final a = p.a.toInt();
    if (a == 0) {
      visited[idx] = true;
      return;
    }
    if (_nearWhite(r, g, b)) {
      visited[idx] = true;
      q.add(idx);
    }
  }

  // Seed from all edges.
  for (var x = 0; x < w; x++) {
    tryAdd(x, 0);
    tryAdd(x, h - 1);
  }
  for (var y = 0; y < h; y++) {
    tryAdd(0, y);
    tryAdd(w - 1, y);
  }

  while (q.isNotEmpty) {
    final idx = q.removeFirst();
    final x = idx % w;
    final y = idx ~/ w;

    // Make transparent.
    final p = im.getPixel(x, y);
    im.setPixelRgba(x, y, p.r.toInt(), p.g.toInt(), p.b.toInt(), 0);

    // 4-neighbors
    tryAdd(x + 1, y);
    tryAdd(x - 1, y);
    tryAdd(x, y + 1);
    tryAdd(x, y - 1);
  }

  final out = img.encodePng(im, level: 6);
  File(outputPath).writeAsBytesSync(out);
  stdout.writeln('Wrote: $outputPath');
}

