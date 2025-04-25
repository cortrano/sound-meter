cmake_minimum_required(VERSION 3.4.1)
project(AudioProcessor)
add_library(audio_processor SHARED audio_processor.c)
target_link_libraries(audio_processor m) # Для math.h