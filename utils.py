import sys
class XorShift64PrngIter:
    MOD = 2 ** 64
    def __init__(self, initial_state = 1):
        "Pass 0 as initial_state to get time-based initialization"
        while not initial_state or not (initial_state % self.MOD):
            import time
            initial_state = time.time_ns()
        self.state = initial_state % self.MOD

    def __iter__(self): return self

    def __next__(self):
        self.state ^= self.state >> 12
        self.state ^= (self.state << 25) % self.MOD
        self.state ^= self.state >> 27
        return (self.state * 2685821657736338717) % self.MOD

def main(cmdline=sys.argv):
    class Args:
        unparsed_params_left = list(cmdline[1:])

        @classmethod
        def _next_arg(cls, fallback_value=None):
            return cls.unparsed_params_left.pop(0) if cls.unparsed_params_left else fallback_value

    Args.dev = str(Args._next_arg("/dev/x"))

