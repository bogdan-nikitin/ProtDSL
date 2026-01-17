#pragma once
#include <stdexcept>


class ExitSignal : public std::exception {
    int code;
public:
    ExitSignal(int code) : code{code} {}

    int get_code() {
        return code;
    }
};
