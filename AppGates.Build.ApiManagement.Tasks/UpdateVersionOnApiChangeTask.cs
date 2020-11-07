using LibGit2Sharp;
using Microsoft.Build.Framework;
using Microsoft.Build.Utilities;
using Nerdbank.GitVersioning;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices.ComTypes;

namespace AppGates.Build.ApiManagement.Tasks
{
    public class UpdateVersionOnApiChange
    {
        private DirectoryInfo ProjectDirectory  { get;  }

        public UpdateVersionOnApiChange(DirectoryInfo projectDirectory,
            FileInfo gitVersionFile = null,
            FileInfo publicApiShippedFile = null,
            FileInfo publicApiUnshippedFile= null, 
            FileInfo packageLockFile = null)
        {
            ProjectDirectory = projectDirectory;
            GitVersionFile = gitVersionFile ?? throw new ArgumentException(nameof(gitVersionFile));
            PublicApiShippedFile = publicApiShippedFile;
            PublicApiUnshippedFile = publicApiUnshippedFile;
            PackageLockFile = packageLockFile;
        }

        private FileInfo GitVersionFile{get;}
        private FileInfo PublicApiShippedFile {get;}
        private FileInfo PublicApiUnshippedFile{get;}
        private FileInfo PackageLockFile{ get;}

        public VersionOptions UpdateVersion(Func<(DirectoryInfo RepositoryDirectory, StatusOptions Options), IEnumerable<StatusEntry>> getStatus)
        {
            var options = VersionFile.GetVersion(
                GitVersionFile.DirectoryName);


            this.UpdateVersion(o=> getStatus((this.ProjectDirectory,o)), options,
                (this.PublicApiShippedFile, true),
                (this.PublicApiUnshippedFile, false),
                (this.PackageLockFile, false));

            return options;
        }
        private void UpdateVersion(Func<StatusOptions, IEnumerable<StatusEntry>> getStatus, VersionOptions options, params (FileInfo IndicatorFile, bool IndicatesMajorChange)[] indicators)
        {
            var indicatorFileStatus = getStatus(
              new StatusOptions() { PathSpec = indicators.Select(f => f.IndicatorFile.FullName).ToArray() })
                .Where(x => x.State != FileStatus.Unaltered).ToArray();

            var changed = indicatorFileStatus.Join(indicators, se => se.FilePath, f => f.IndicatorFile.FullName, (e, i) => (Indicator: i, Status: e)).ToArray();


            var previousVersion = options.Version.Version;

            var major = previousVersion.Major;
            var minor = previousVersion.Minor;

            if (changed.Any(m => m.Indicator.IndicatesMajorChange))
            {
                ++major;
                minor = 0;
            }
            else if (changed.Any())
            {
                ++minor;
            }
            options.Version = new SemanticVersion(
                    new System.Version(major, minor,
                    previousVersion.Build), options.Version.Prerelease,
                    options.Version.BuildMetadata);
        }

    }
    public class UpdateVersionOnApiChangeTask: Task
    {
        private DirectoryInfo ProjectDirectory => new DirectoryInfo(this.ProjectDirectoryPath);
        private FileInfo GitVersionFile => new FileInfo(GitVersionFilePath);
        private FileInfo PublicApiShippedFile => new FileInfo(this.PublicApiShippedFilePath);
        private FileInfo PublicApiUnshippedFile => new FileInfo(this.PublicApiUnshippedFilePath);
        private FileInfo PackageLockFile => new FileInfo(this.PackageLockFilePath);
        [Required]
        public string ProjectDirectoryPath { get; set; }

        [Required]
        public string GitVersionFilePath { get; set; }

        [Required]
        public string PublicApiShippedFilePath { get; set; }

        [Required]
        public string PublicApiUnshippedFilePath { get; set; }

        [Required]
        public string PackageLockFilePath { get; set; }


        public override bool Execute()
        {
            var newVersion = new UpdateVersionOnApiChange(this.ProjectDirectory).UpdateVersion(
                x => GitExtensions.OpenGitRepo(x.RepositoryDirectory.FullName).RetrieveStatus(x.Options));

            VersionFile.SetVersion(this.ProjectDirectory.FullName, newVersion);
            
            return true;
        }

    }
}
