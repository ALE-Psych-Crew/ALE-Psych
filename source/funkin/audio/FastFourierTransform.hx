package funkin.audio;

@:nullSafety
class FastFourierTransform
{
  public static function fft(input:Array<Complex>):Array<Complex> return do_fft(input, false);

  public static function rfft(input:Array<Float>):Array<Complex>
  {
    final s = fft(input.map(Complex.fromReal));
    return s.slice(0, Std.int(s.length / 2) + 1);
  }

  public static function ifft(input:Array<Complex>):Array<Complex> return do_fft(input, true);

  static function do_fft(input:Array<Complex>, inverse:Bool):Array<Complex>
  {
    final n = nextPow2(input.length);
    var ts = [for (i in 0...n) if (i < input.length) input[i] else Complex.zero];
    var fs = [for (_ in 0...n) Complex.zero];
    ditfft2(ts, 0, fs, 0, n, 1, inverse);
    return inverse ? fs.map(z -> z.scale(1 / n)) : fs;
  }

  static function ditfft2(time:Array<Complex>, t:Int, freq:Array<Complex>, f:Int, n:Int, step:Int, inverse:Bool):Void
  {
    if (n == 1)
    {
      freq[f] = time[t].copy();
    }
    else
    {
      final halfLen = Std.int(n / 2);
      ditfft2(time, t, freq, f, halfLen, step * 2, inverse);
      ditfft2(time, t + step, freq, f + halfLen, halfLen, step * 2, inverse);
      for (k in 0...halfLen)
      {
        final twiddle = Complex.exp((inverse ? 1 : -1) * 2 * Math.PI * k / n);
        final even = freq[f + k].copy();
        final odd = freq[f + k + halfLen].copy();
        freq[f + k] = even + twiddle * odd;
        freq[f + k + halfLen] = even - twiddle * odd;
      }
    }
  }

  static function dft(ts:Array<Complex>, ?inverse:Bool):Array<Complex>
  {
    if (inverse == null) inverse = false;
    final n = ts.length;
    var fs = new Array<Complex>();
    fs.resize(n);
    for (f in 0...n)
    {
      var sum = Complex.zero;
      for (t in 0...n)
      {
        sum += ts[t] * Complex.exp((inverse ? 1 : -1) * 2 * Math.PI * f * t / n);
      }
      fs[f] = inverse ? sum.scale(1 / n) : sum;
    }
    return fs;
  }

  static function nextPow2(x:Int):Int
  {
    if (x < 2) return 1;
    else if ((x & (x - 1)) == 0) return x;
    var pow = 2;
    x--;
    while ((x >>= 1) != 0)
      pow <<= 1;
    return pow;
  }

  static function main()
  {
    final Fs = 44100.0;
    final N = 512;
    final halfN = Std.int(N / 2);

    final freqs = [5919.911];
    final ts = [for (n in 0...N) Lambda.fold(freqs.map(f -> Math.sin(2 * Math.PI * f * n / Fs)), (a, b) -> a + b, 0.0)];

    final fs_pos = rfft(ts);
    final fs_fft = new OffsetArray([for (k in -(halfN - 1)...0) fs_pos[-k].conj()].concat(fs_pos), -(halfN - 1));

    final fs_dft = new OffsetArray(OffsetArray.circShift(dft(ts.map(Complex.fromReal)), halfN - 1), -(halfN - 1));
    final fs_err = [for (k in -(halfN - 1)...halfN) fs_fft[k] - fs_dft[k]];
    final max_fs_err = Lambda.fold(fs_err.map(z -> z.magnitude), Math.max, Math.NEGATIVE_INFINITY);

    final magnitudes = fs_fft.array.map(z -> z.magnitude);
    final peakIndices = [for (i in 1...magnitudes.length - 1)
      if (magnitudes[i] > magnitudes[i - 1] && magnitudes[i] > magnitudes[i + 1]) i];
    final freqis = peakIndices
      .map(k -> (k - (halfN - 1)) * Fs / N)
      .filter(f -> f >= 0);
    if (freqis.length == freqs.length)
    {
      final freqs_err = [for (i in 0...freqs.length) freqis[i] - freqs[i]];
      final max_freqs_err = Lambda.fold(freqs_err.map(Math.abs), Math.max, Math.NEGATIVE_INFINITY);
    }

    final ts_ifft = ifft(OffsetArray.circShift(fs_fft.array, -(halfN - 1)).map(z -> z.scale(1 / Fs)));
    final ts_err = [for (n in 0...N) ts_ifft[n].scale(Fs).real - ts[n]];
    final max_ts_err = Lambda.fold(ts_err.map(Math.abs), Math.max, Math.NEGATIVE_INFINITY);
  }
}
