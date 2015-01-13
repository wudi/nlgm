nginx-lua-imagemagick
=====================

##Dependencies(环境依赖)

**Lua JIT**

http://luajit.org/download.html


**Nginx && lua-nginx-module && ngx_devel_kit**

http://nginx.org

https://github.com/openresty/lua-nginx-module

https://github.com/simpl/ngx_devel_kit

**nginx compile module useage（Nginx打模块）**

*Recommended use the [OpenResty](http://openresty.org/cn/index.html) project.

```
configure \
...
--add-module=/path/lua-nginx-module \
--add-module=/path/ngx_devel_kit 

make && make install
```

**ImageMagick**

http://www.imagemagick.org/

##Usage

Modify

`nginx-server.conf`

1. `convert_bin`  imagemagick_install_path/bin/convert
2. `rewrite_by_lua_file` nginx-imagemagick.lua save path

if want to allow more image size, please modify the `image_sizes` variable in **nginx-imagemagick.lua**

**Don't forget reload the Nginx.**


----------


**original image(原始图片)**

http://domain.com/cdn_assets/photo/abc.jpg

**thumb image 320x320 (缩略图)**

http://domain.com/cdn_assets/photo/abc_320x320.jpg

**thumb image 640x640 (缩略图)**

http://domain.com/cdn_assets/photo/abc_640x640.jpg

**and etc.**



