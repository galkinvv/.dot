#include <stdio.h>
#include <dlfcn.h>
#include <malloc.h>
#include <string.h>
#include <atomic>

//deduced-type reinterpret cast
template<class From> struct reinterpret_auto
{
	reinterpret_auto(const From& data):m_data(data){}
	const From& m_data;
	template<class To>	operator To(){return reinterpret_cast<To>(m_data);}
};

/**
 * Literal class type that wraps a constant expression string.
 *
 * Uses implicit conversion to allow templates to *seemingly* accept constant strings.
 */
template<size_t N>
struct StringLiteral {
    constexpr StringLiteral(const char (&str)[N]) {
        for(auto i =N; i>0; --i)
        {
        	value[i-1] = str[i-1];
        }
    }
    
    char value[N];
};

template<StringLiteral name, class Func>
Func LazyDynLoad(Func) {
	static std::atomic<void*> cache{};
	void* cached = cache.load();
	if (cached == nullptr)
	{
		cached = dlsym(RTLD_NEXT, name.value);
		cache.store(cached);
	}
	return reinterpret_auto(cached);
}

/*
const size_t kMinSizeToPrint = 0x1000;

void print_clock()
{
	timespec t = {};
	clock_gettime(CLOCK_MONOTONIC, &t);
	fprintf(stderr, "%6ld.%9ld:", t.tv_sec, t.tv_nsec);	
}
void *memset(void *ptr, int c, size_t size)
{
	LazyDynLoad<__func__>(memset)(ptr, c, size);
	if (size > kMinSizeToPrint)
	{
		print_clock();
		fprintf(stderr, "memset(0x%zx)=%p\n", size, ptr);
	}

	return ptr;
}
*/
