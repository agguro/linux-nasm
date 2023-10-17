//------------------------------------------------
//               Ch06_07.cpp
//------------------------------------------------

#include "stdafx.h"
#include <iostream>
#include <iomanip>
#include "Ch06_07.h"
#include "Matrix.h"

using namespace std;

void AvxMat4x4TransposeF32(Matrix<float>& m_src)
{
    const size_t nr = 4;
    const size_t nc = 4;
    Matrix<float> m_des1(nr ,nc);
    Matrix<float> m_des2(nr ,nc);

    Matrix<float>::Transpose(m_des1, m_src);
    AvxMat4x4TransposeF32_(m_des2.Data(), m_src.Data());

    cout << fixed << setprecision(1);
    m_src.SetOstream(12, "  ");
    m_des1.SetOstream(12, "  ");
    m_des2.SetOstream(12, "  ");

    cout << "Results for AvxMat4x4TransposeF32\n";
    cout << "Matrix m_src \n" << m_src << '\n';
    cout << "Matrix m_des1\n" << m_des1 << '\n';
    cout << "Matrix m_des2\n" << m_des2 << '\n';

    if (m_des1 != m_des2)
        cout << "\nMatrix compare failed - AvxMat4x4TransposeF32\n";
}

int main()
{
    const size_t nr = 4;
    const size_t nc = 4;
    Matrix<float> m_src(nr ,nc);

    const float src_row0[] = {  2,  7,  8,  3 };
    const float src_row1[] = { 11, 14, 16, 10 };
    const float src_row2[] = { 24, 21, 27, 29 };
    const float src_row3[] = { 31, 34, 38, 33 };

    m_src.SetRow(0, src_row0);
    m_src.SetRow(1, src_row1);
    m_src.SetRow(2, src_row2);
    m_src.SetRow(3, src_row3);

    AvxMat4x4TransposeF32(m_src);
    AvxMat4x4TransposeF32_BM();
    return 0;
}
