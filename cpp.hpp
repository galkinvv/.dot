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


#include <cstdint>
#include <iostream>
#include <linux/serial.h>

struct SizeOffset {
  std::string name;
  uintptr_t size = {};
  uintptr_t range = {};
  uintptr_t offset = {};
};


template <class Structure, class Field>
Structure get_containing_struct(Field Structure::* pointer_to_member);


template <auto pointer_to_member>
SizeOffset calc_size_offset()
{
  typedef decltype(get_containing_struct(pointer_to_member)) Structure;
  alignas(Structure) char container_space[sizeof(Structure)] = {};
  Structure* fake_structure = reinterpret_cast<Structure*>(container_space);
  SizeOffset result = {};
  result.name = __PRETTY_FUNCTION__;
  result.size = sizeof(Structure);
  result.offset = reinterpret_cast<uintptr_t>(&(fake_structure->*pointer_to_member))
                  - reinterpret_cast<uintptr_t>(fake_structure);
  result.range = sizeof(fake_structure->*pointer_to_member);
  return result;
}

void print_size_offset(const SizeOffset& info)
{
  std::cout << info.name << " " << info.offset << "-" << (info.offset+info.range) << " of " << info.size << std::endl;
}


int main()
{
  print_size_offset(calc_size_offset<&serial_struct::iomem_base>());
  print_size_offset(calc_size_offset<&serial_struct::iomap_base>());
  return 0;
}
