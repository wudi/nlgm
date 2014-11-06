nginx-lua-imagemagick
=====================

##Dependencies

**Lua JIT**

http://luajit.org/download.html


**Nginx && lua-nginx-module**

http://nginx.org

https://github.com/openresty/lua-nginx-module


**nginx compile**

```
configure \
...
--add-module=/path/lua-nginx-module

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


**original image**

http://domain.com/cdn_assets/photo/abc.jpg

**thumb image 320x320**

http://domain.com/cdn_assets/photo/abc_320x320.jpg

**thumb image 640x640**

http://domain.com/cdn_assets/photo/abc_640x640.jpg

**and etc.**



