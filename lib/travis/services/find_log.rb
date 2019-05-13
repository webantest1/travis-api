require 'travis/services/base'

module Travis
  module Services
    class FindLog < Base
      register :find_log

      scope_access!

      def run(options = {})
        result
      end

      private def result
        if params[:id]
          # as we don't have the job id, we first need to get the log to check
          # permissions
          remote_log = Travis::RemoteLog.find_by_id(Integer(params[:id]))
          if remote_log && scope(:job).find_by_id(remote_log.job_id)
            remote_log
          end
        elsif params[:job_id]
          # this is only to check permissions with scope_check!

          job = scope(:job).find_by_id(params[:job_id])
          if job
            platform = platform_for(job)
            id = id_for(job)
            Travis::RemoteLog.find_by_job_id(id, platform: platform)
          end
        end
      end

      private def platform_for(job)
        return "org" if deployed_on_org?
        return "org" if job.migrated? && !job.restarted_after_migration?
        "com"
      end

      private def id_for(job)
        return job.org_id if job.migrated? && !job.restarted_after_migration?
        job.id
      end

      private def deployed_on_org?
        ENV["TRAVIS_SITE"] == "org"
      end
    end
  end
end
