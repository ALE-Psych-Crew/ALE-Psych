package cpp;

#if android
import extension.haptics.android.HapticAndroid;
#elseif ios
import extension.haptics.ios.HapticIOS;
#end

class MobileAPI
{
	public static function vibrateOneShot(duration:Float, amplitude:Float, sharpness:Float):Void
	{
		#if android
		HapticAndroid.vibrateOneShot(Math.floor(duration * 1000), Math.floor(Math.max(1, Math.min(255, amplitude * 255))));
		#elseif ios
		HapticIOS.vibrateOneShot(duration, Math.max(0, Math.min(1, amplitude)), Math.max(0, Math.min(1, sharpness)));
		#end
	}

	public static function vibratePattern(durations:Array<Float>, amplitudes:Array<Float>, sharpnesses:Array<Float>):Void
	{
		#if android
		final intTimings:Array<Int> = [0];

		for (i in 0...durations.length)
			intTimings.push(Math.floor(durations[i] * 1000));

		final intAmplitudes:Array<Int> = [0];

		for (i in 0...amplitudes.length)
			intAmplitudes.push(Math.floor(Math.max(1, Math.min(255, amplitudes[i] * 255))));

		HapticAndroid.vibratePattern(intTimings, intAmplitudes);
		#elseif ios
		final singleAmplitudes:Array<Single> = [];

		for (i in 0...amplitudes.length)
			singleAmplitudes[i] = (amplitudes[i] : Single);

		final singleSharpnesses:Array<Single> = [];

		for (i in 0...sharpnesses.length)
			singleSharpnesses[i] = (sharpnesses[i] : Single);

		HapticIOS.vibratePattern(durations, singleAmplitudes, singleSharpnesses);
		#end
	}
}