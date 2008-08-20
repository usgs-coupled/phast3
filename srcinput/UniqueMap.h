#ifndef _UNIQUE_MAP_
#define _UNIQUE_MAP_

#include <vector>
#include <map>
#include <cassert>

template<class _Ty>
class UniqueMap
{
public:

	typedef typename std::vector<_Ty>::iterator iterator;
	typedef typename std::vector<_Ty>::const_iterator const_iterator;

	typedef typename std::vector<_Ty>::reference reference;
	typedef typename std::vector<_Ty>::const_reference const_reference;

	size_t push_back(const _Ty& val)
	{
		assert(this->data.size() == this->inverse_map.size());
		std::map<_Ty, size_t>::iterator it = this->inverse_map.find(val);
		if (it == this->inverse_map.end())
		{
			std::map<_Ty, size_t>::value_type v(val, this->data.size());
			this->inverse_map.insert(v);
			this->data.push_back(val);
			assert(this->data.size() == this->inverse_map.size());
			return v.second;
		}
		return it->second;
	}

	size_t size(void)const
	{
		assert(inverse_map.size() == data.size());
		return data.size();
	}

	iterator begin(void)
	{
		return data.begin();
	}

	const_iterator begin(void)const
	{
		return data.begin();
	}

	iterator end(void)
	{
		return data.end();
	}

	const_iterator end(void)const
	{
		return data.end();
	}

	void replace(size_t i, const _Ty& val)
	{
		assert(i < data.size());
		if (i < data.size())
		{
			data[i] = val;
		}
	}

	void erase(size_t i)
	{
		assert(i < data.size());
		if (i < data.size())
		{
			data.erase(data.begin() + i);
		}
	}

	void clear(void)
	{
		data.clear();
		inverse_map.clear();
	}

	iterator find(size_t i)
	{
		assert(i < data.size());
		if (i < data.size())
		{
			return data.begin() + i;
		}
		return data.end();
	}

	reference at(size_t i)
	{
		assert(i < data.size());
		return data.at(i);
	}

	const_reference at(size_t i) const
	{
		assert(i < data.size());
		return data.at(i);
	}

protected:
	std::vector<_Ty> data;
	std::map<_Ty, size_t> inverse_map;
};

#endif // _UNIQUE_MAP_