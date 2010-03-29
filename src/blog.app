{application, blog,
 [{description, "blog"},
  {vsn, "0.1"},
  {modules, [
    blog,
    blog_app,
    blog_sup,
    blog_deps,
    item,
    item_resource
  ]},
  {registered, []},
  {mod, {blog_app, []}},
  {env, []},
  {applications, [kernel, stdlib, crypto]}]}.
