#!/usr/bin/env ruby -w
  require 'time'
  require 'pp'
  require 'fileutils'
  require 'logger'

  $dir_denim  = '/home/denimuser/builds/'
  $dir_seam   = '/home/denimuser/seam-builds/'
  $dir_rivet  = '/home/denimuser/rivet-builds/'

  $logger = Logger.new(STDOUT)
  $logger.level = Logger::INFO

  # have to paratmetrize the number of builds to cleanup

  # do the builds cleanup
  def build_cleanup (dir_path, build_path )
    allowed_builds_count = 2     # number of allowed builds
    rm_build = []

    if dir_path.eql? $dir_rivet
      Dir.chdir(dir_path)
    else
      Dir.chdir(dir_path+build_path)
    end
    @build_list = Dir.glob("*/").sort_by{|f| File.mtime(f)}
    if @build_list.size > allowed_builds_count
       rm_build = @build_list.slice! ( 0..@build_list.size - allowed_builds_count - 1 )
    end
    # remove builds
    rm_build.reject(&:empty?)
    if !rm_build.empty?
      rm_build.each do |build|
        $logger.info "Removing build #{build} in dir #{dir_path} "
        FileUtils.rm_rf(build)
      end
    end
  end

  #branch cleanup and invoke build cleanup
  def branch_cleanup(branch_path)
    allowed_branch_count = 2
    # check dir exists, cleanup for each branch
    if File.exist? branch_path
      Dir.chdir(branch_path)
      $logger.info "Cleaning up branches for dir #{branch_path}"
      @branch_list = Dir.glob("*/").sort_by{|f| File.mtime(f)}
      if @branch_list.size > allowed_branch_count
        rm_branch = @branch_list.slice! (0..@branch_list.size - allowed_branch_count - 1)
        rm_branch.reject(&:empty?)
        if !rm_branch.empty?
          rm_branch.each do |old_branch|
            $logger.info "Removing the branch #{old_branch} "
            FileUtils.rm_rf (old_branch)
          end
        end
        @branch_list = @branch_list - rm_branch
      end
      @branch_list.each { |branch| build_cleanup(branch_path, branch) }
    end
  end


  # display the space available on drive
  before_cleanup =  `df -P | grep /dev/xvda1 | awk '{print $5}' `
  $logger.info "Disk space before cleanup  #{before_cleanup} "
  # cleanup branches on Denim and Seam
  branch_cleanup($dir_denim)
  branch_cleanup($dir_seam)


  # cleanup for Rivet
  if File.exist? $dir_rivet
    rivet_branch = " "
    build_cleanup($dir_rivet, rivet_branch )
  end

 after_cleanup = `df -P | grep /dev/xvda1 | awk '{print $5}' `
 $logger.info "Disk space after cleanup  #{after_cleanup} "
 $logger.close
