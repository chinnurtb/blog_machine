{application, blog,
 [{description, "blog"},
  {vsn, "0.1"},
  {modules, [
    blog,
    blog_app,
    blog_sup,
    blog_deps,
    blog_error_handler,
    item,
    item_resource,
    erltl
  ]},
  {registered, []},
  {mod, {blog_app, []}},
  {env, []},
  {applications, [kernel, stdlib, crypto]}]}.
