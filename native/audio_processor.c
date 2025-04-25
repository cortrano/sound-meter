#include <math.h>
#include <stdint.h>

double calculate_db(int16_t* samples, int32_t sample_count) {
    if (sample_count <= 0) return 0.0;
    
    // Вычисляем RMS
    double sum = 0.0;
    for (int32_t i = 0; i < sample_count; i++) {
        double sample = samples[i] / 32768.0;
        sum += sample * sample;
    }
    double rms = sqrt(sum / sample_count);
    
    // Преобразуем в децибелы
    const double reference = 0.00002;
    if (rms <= 0) return 0.0;
    return 20.0 * log10(rms / reference);
}