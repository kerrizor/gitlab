class Gitlab::Client
  # Defines methods related to repositories.
  # @see https://docs.gitlab.com/ce/api/repositories.html
  module Repositories
    # Get file tree project (root level).
    #
    # @example
    #   Gitlab.tree(42)
    #   Gitlab.tree(42, { path: 'Gemfile' })
    #
    # @param  [Integer, String] project The ID or name of a project.
    # @param  [Hash] options A customizable set of options.
    # @option options [String] :path The path inside repository.
    # @option options [String] :ref_name The name of a repository branch or tag.
    # @return [Gitlab::ObjectifiedHash]
    def tree(project, options={})
      get("/projects/#{url_encode project}/repository/tree", query: options)
    end
    alias_method :repo_tree, :tree

    # Get project repository archive
    #
    # @example
    #   Gitlab.repo_archive(42)
    #   Gitlab.repo_archive(42, 'deadbeef')
    #
    # @param  [Integer, String] project The ID or name of a project.
    # @param  [String] ref The commit sha, branch, or tag to download.
    # @return [Gitlab::FileResponse]
    def repo_archive(project, ref = 'master')
      get("/projects/#{url_encode project}/repository/archive",
          format: nil,
          headers: { Accept: 'application/octet-stream' },
          query: { sha: ref },
          parser: proc { |body, _|
            if body.encoding == Encoding::ASCII_8BIT # binary response
              ::Gitlab::FileResponse.new StringIO.new(body, 'rb+')
            else # error with json response
              ::Gitlab::Request.parse(body)
            end
          })
    end

    # Compares branches, tags or commits.
    #
    # @example
    #   Gitlab.compare(42, 'master', 'feature/branch')
    #   Gitlab.repo_compare(42, 'master', 'feature/branch')
    #
    # @param [Integer] project The ID of a project.
    # @param [String] from The commit SHA or branch name of from branch.
    # @param [String] to The commit SHA or branch name of to branch.
    # @return [Gitlab::ObjectifiedHash]
    def compare(project, from, to)
      get("/projects/#{url_encode project}/repository/compare", query: { from: from, to: to })
    end
    alias_method :repo_compare, :compare
  end
end
