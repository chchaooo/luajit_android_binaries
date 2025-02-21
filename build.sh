#!/usr/bin/env sh
# From https://github.com/gudzpoz/luajava/blob/main/luajit/jni/scripts/build-android.sh
# From https://github.com/mjansson/lua_lib/blob/master/lua/luajit/build-android.sh
# Fixed https://github.com/LuaJIT/LuaJIT/issues/440#issuecomment-438809840

LUAJIT=luajit

cd $LUAJIT

LUAJIT_SRC=src
OPT_DIR=../opt


rm -rf $OPT_DIR
mkdir -p $OPT_DIR
rm *.a 1>/dev/null 2>/dev/null

HOST_OS=linux
NDK="${ANDROID_NDK_HOME:-$ANDROID_NDK_LATEST_HOME}"
TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/$HOST_OS-x86_64
NDKB=$TOOLCHAIN/bin
NDKAPI=21
echo "NDK: $NDK"
echo "TOOLCHAIN: $TOOLCHAIN"

echo "########## Building armv7-a ##########"
TARGET=armv7a-linux-androideabi
NDKP=$NDKB/${TARGET}-
NDKCC=$NDKB/${TARGET}${NDKAPI}-clang
NDKARCH="-march=armv7-a -mhard-float -mfpu=vfpv3-d16 -mfloat-abi=softfp -D_NDK_MATH_NO_SOFTFP=1 -marm -DNO_RTLD_DEFAULT=1"
make HOST_CC="gcc -m32 -I/usr/i686-linux-gnu/include" CROSS=$NDKP \
     STATIC_CC=$NDKCC DYNAMIC_CC="$NDKCC -fPIC" \
     TARGET_LD=$NDKCC TARGET_AR="$NDKB/llvm-ar rcus" TARGET_STRIP=$NDKB/llvm-strip \
     CFLAGS=-fPIC TARGET_FLAGS="$NDKARCH" \
     clean
make HOST_CC="gcc -m32 -I/usr/i686-linux-gnu/include" CROSS=$NDKP \
     STATIC_CC=$NDKCC DYNAMIC_CC="$NDKCC -fPIC" \
     TARGET_LD=$NDKCC TARGET_AR="$NDKB/llvm-ar rcus" TARGET_STRIP=$NDKB/llvm-strip \
     CFLAGS=-fPIC TARGET_FLAGS="$NDKARCH" \
     amalg
mkdir -p $OPT_DIR/armeabi-v7a
mv $LUAJIT_SRC/libluajit.a $OPT_DIR/armeabi-v7a/libluajit.a


echo "########## Building arm64-v8a ##########"
TARGET=aarch64-linux-android
NDKP=$NDKB/${TARGET}-
NDKCC=$NDKB/${TARGET}${NDKAPI}-clang
NDKARCH="-DLJ_ABI_SOFTFP=0 -DLJ_ARCH_HASFPU=1 -DLUAJIT_ENABLE_GC64=1 -DNO_RTLD_DEFAULT=1"
# 清理之前的构建
make HOST_CC="gcc -m64" CROSS=$NDKP \
     STATIC_CC=$NDKCC DYNAMIC_CC="$NDKCC -fPIC" \
     TARGET_LD=$NDKCC TARGET_AR="$NDKB/llvm-ar rcus" TARGET_STRIP=$NDKB/llvm-strip \
     CFLAGS=-fPIC TARGET_FLAGS="$NDKARCH" \
     clean
# 编译生成静态库 (.a)
make HOST_CC="gcc -m64" CROSS=$NDKP \
     STATIC_CC=$NDKCC DYNAMIC_CC="$NDKCC -fPIC" \
     TARGET_LD=$NDKCC TARGET_AR="$NDKB/llvm-ar rcus" TARGET_STRIP=$NDKB/llvm-strip \
     CFLAGS=-fPIC TARGET_FLAGS="$NDKARCH" \
     amalg
mkdir -p $OPT_DIR/arm64-v8a
mv $LUAJIT_SRC/libluajit.a $OPT_DIR/arm64-v8a/libluajit.a
# 编译生成共享库 (.so)
make HOST_CC="gcc -m64" CROSS=$NDKP \
     STATIC_CC=$NDKCC DYNAMIC_CC="$NDKCC -fPIC" \
     TARGET_LD=$NDKCC TARGET_AR="$NDKB/llvm-ar rcus" TARGET_STRIP=$NDKB/llvm-strip \
     CFLAGS=-fPIC TARGET_FLAGS="$NDKARCH" \
     TARGET_SHLDFLAGS="-shared" \
     libluajit.so
mv $LUAJIT_SRC/libluajit.so $OPT_DIR/arm64-v8a/libluajit.so
