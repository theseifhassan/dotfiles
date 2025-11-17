#ifndef CONFIG_H
#define CONFIG_H

// String used to delimit block outputs in the status.
#define DELIMITER " | "

// Maximum number of Unicode characters that a block can output.
#define MAX_BLOCK_OUTPUT_LENGTH 45

// Control whether blocks are clickable.
#define CLICKABLE_BLOCKS 0

// Control whether a leading delimiter should be prepended to the status.
#define LEADING_DELIMITER 0

// Control whether a trailing delimiter should be appended to the status.
#define TRAILING_DELIMITER 0

// Define blocks for the status feed as X(icon, cmd, interval, signal).
#define BLOCKS(X)             \
    X("", "dwmblock.media.sh",       0, 12)   \
    X("", "dwmblock.volume.sh",      0, 10)   \
    X("", "dwmblock.network.sh",    30,  0)   \
    X("", "dwmblock.memory.sh",     30,  0)   \
    X("", "dwmblock.brightness.sh", 30, 11)   \
    X("", "dwmblock.battery.sh",     5,  0)   \
    X("", "dwmblock.date.sh",        5,  0)   \

#endif  // CONFIG_H
