# Include hook code here
require 'blog_post'
require 'blog_comment'
Ansuz::PluginManagerInstance.register_plugin_nav('Blog', '/articles')
Ansuz::PluginManagerInstance.register_admin_plugin_nav('Blog Posts', '/admin/blog_posts')
