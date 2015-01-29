#ifndef _UNIQUE_MAP_
#define _UNIQUE_MAP_

#include <vector>
#include <map>
#include <cassert>

template < class _Ty > class UniqueMap
{
  public:

	typedef typename std::vector < _Ty >::iterator iterator;
	typedef typename std::vector < _Ty >::const_iterator const_iterator;

	typedef typename std::vector < _Ty >::reference reference;
	typedef typename std::vector < _Ty >::const_reference const_reference;

	size_t push_back(const _Ty & val)
	{
		assert(this->data.size() == this->inverse_map.size());
		typename std::map < _Ty, size_t >::iterator it =
			this->inverse_map.find(val);
		if (it == this->inverse_map.end())
		{
			typename std::map < _Ty, size_t >::value_type v(val,
															this->data.
															size());
			this->inverse_map.insert(v);
			this->data.push_back(val);
			assert(this->data.size() == this->inverse_map.size());
			return v.second;
		}
		return it->second;
	}

	size_t size(void) const
	{
		assert(this->inverse_map.size() == this->data.size());
		return this->data.size();
	}

	iterator begin(void)
	{
		return this->data.begin();
	}

	const_iterator begin(void) const
	{
		return this->data.begin();
	}

	iterator end(void)
	{
		return this->data.end();
	}

	const_iterator end(void) const
	{
		return this->data.end();
	}

	void replace(size_t i, const _Ty & val)
	{
		assert(i < this->data.size());
		if (i < this->data.size())
		{
			typename std::map < _Ty, size_t >::iterator it =
				this->inverse_map.find(this->data[i]);
			assert(it != this->inverse_map.end());
			if (it != this->inverse_map.end())
			{
				this->inverse_map.erase(it);
				typename std::map < _Ty, size_t >::value_type v(val, i);
				this->inverse_map.insert(v);
			}
			this->data[i] = val;
		}
	}

	void erase(size_t i)
	{
		assert(i < this->data.size());
		if (i < this->data.size())
		{
			typename std::map < _Ty, size_t >::iterator it =
				this->inverse_map.find(this->data[i]);
			assert(it != this->inverse_map.end());
			if (it != this->inverse_map.end())
			{
				this->inverse_map.erase(it);
			}
			this->data.erase(data.begin() + i);
		}
	}

	void clear(void)
	{
		this->data.clear();
		this->inverse_map.clear();
	}

	iterator find(size_t i)
	{
		if (i == std::string::npos)
			return this->data.end();
		assert(i < this->data.size());
		if (i < this->data.size())
		{
			return this->data.begin() + i;
		}
		return this->data.end();
	}

	reference at(size_t i)
	{
		assert(i < this->data.size());
		return this->data.at(i);
	}

	const_reference at(size_t i) const
	{
		assert(i < this->data.size());
		return this->data.at(i);
	}

  protected:
	  std::vector < _Ty > data;
	std::map < _Ty, size_t > inverse_map;
};

#endif // _UNIQUE_MAP_
