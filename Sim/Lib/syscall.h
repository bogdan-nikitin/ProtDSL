#pragma once
#include <stdexcept>


class ExitSignal : public std::exception {
    int code;
public:
    ExitSignal(int code) : code{code} {}

    int get_code() const {
        return code;
    }
};

class BadSyscall : public std::runtime_error {
    using std::runtime_error::runtime_error;
};
