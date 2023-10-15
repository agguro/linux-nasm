//modifications
#pragma once
#include "../../commonfiles/mat4x4.h"

// SsePackedFloatingPointMatrix4x4.cpp function declarations
//extern void SsePfpMatrix4x4MultiplyCpp(Mat4x4 m_des, Mat4x4 m_src1, Mat4x4 m_src2);
//extern void SsePfpMatrix4x4TransformVectorsCpp(Vec4x1* v_des, Mat4x4 m_src, Vec4x1* v_src, int num_vec);

// SsePackedFloatingPointMatrix4x4_.asm function declarations
extern "C" void SsePfpMatrix4x4Multiply(Mat4x4 m_des, Mat4x4 m_src1, Mat4x4 m_src2);
extern "C" void SsePfpMatrix4x4TransformVectors(Vec4x1* v_des, Mat4x4 m_src, Vec4x1* v_src, int num_vec);
