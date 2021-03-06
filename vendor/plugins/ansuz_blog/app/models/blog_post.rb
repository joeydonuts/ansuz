class Ansuz
  class JAdams
    class BlogPost < ActiveRecord::Base
      acts_as_taggable
      has_many :blog_comments, :class_name => "Ansuz::JAdams::BlogComment", :order => "created_at DESC"

      def edit_path
        "/blog_posts/#{id}/edit"
      end

      def self.view_partial
        "/blog_posts/blog_post"
      end

      def to_s
        title
      end
    end
  end
end
