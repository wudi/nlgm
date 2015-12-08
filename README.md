NLGM (Nginx Lua GraphicsMagick)
=====================

##Dependencies

**GraphicsMagick**

```
Download

http://sourceforge.net/projects/graphicsmagick/files/graphicsmagick/

tar zxvf  GraphicsMagick-1.3.23.tar.gz

cd GraphicsMagick-1.3.23

1）#yum 已经安装了 libjpeg libpng libjpeg-devel libpng-devel

./configure --prefix=/path/to/graphicsmagick 

2）#独立编译安装  libjpeg  libpng，  configure 需要指定 LDFLAGS  和 CPPFLAGS

./configure --prefix=/path/to/graphicsmagick 'LDFLAGS=-L/path/to/jpeg/lib' 'CPPFLAGS=-I/path/to/jpeg'  'LDFLAGS=-L/path/to/png/lib' 'CPPFLAGS=-I/path/to/png' 

make 

-- make 结果会显示 JPEG v1、PNG  的支持情况，确保支持 JPEG v1、PNG 

make install

```

**Lua JIT**

http://luajit.org/download.html

```
tar zxvf  LuaJIT-2.0.4.tar.gz

cd LuaJIT-2.0.4

make

make install PREFIX=/path/to/luajit-2.0/

export LUAJIT_LIB=/path/to/luajit-2.0/lib
export LUAJIT_INC=/path/to/luajit-2.0/include/luajit-2.0

```


**Nginx && lua-nginx-module && ngx_devel_kit**

http://nginx.org

https://github.com/openresty/lua-nginx-module

https://github.com/simpl/ngx_devel_kit

***nginx compile module useage（Nginx打模块）***

Recommended use the [OpenResty](http://openresty.org/cn/index.html) project.

```
cd nginx-source

./configure --prefix=/opt/nginx \
--with-ld-opt="-Wl,-rpath,/path/to/luajit-2.0/lib" \
--add-module=/path/to/ngx_devel_kit \
--add-module=/path/to/lua-nginx-module

...

make && make install

```

**Test Lua**

```
server {
    listen  80;
    server_name  localhost;
    
    location /lua {
         default_type 'text/plain';
          
         content_by_lua ' ngx.say("Hello World!") ';
     }
}
```

http://domain.com/lua 
  
See "Hello World!" in the page.
  
OK!


##Usage

Please read `nlgm.conf` .

**Notes: Nginx add module U must stop the nginx and restart. (Not -s reload!!) **


##Support Arguments


Arg | Mean 
----|------
s   | size  
q   | quality  
m   | crop mode 
v   | show GraphicsMagick command for debug


##TODO

- [ ] Support delimiter option
- [ ] Support more crop mode
- [ ] Auto create directory use **ngx.thumbnail_dir**
- [ ] Border radius
- [ ] More features from GraphicsMagick

----------

eg: http://domain.com/t_s200x200/e3/3a/324jh3gh4jg32j4gj32g4.jpg
