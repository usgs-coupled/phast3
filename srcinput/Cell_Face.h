#if !defined(CELL_FACE_H_INCLUDED)
#define CELL_FACE_H_INCLUDED
enum Cell_Face
{
  CF_X = 0, CF_Y = 1, CF_Z = 2,
  CF_XN = 3, CF_XP = 4, CF_YN = 5, CF_YP = 6, CF_ZN = 7, CF_ZP = 8,
  CF_NONE = 9,
  CF_UNKNOWN = 10
};

#endif // !defined(CELL_FACE_H_INCLUDED)
