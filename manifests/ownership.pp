# Defined type to manage ownership for a specified path.
#
# This is hacky, yes.  We provide this for a couple of reasons:
#  - IBM software basically wants to be installed as root.  It's possible to
#    install as a different user, but the Installation Manager (the package
#    manager) data won't know about that installation.  To keep things
#    centralized so that we can reliably query it, we install as root.
#  - Since we installed as root, the instance is "owned" by root.  This seems
#    to cause some configuration tasks to fail to run, even if the "profiles"
#    are owned by the service account.  E.g. some tasks attempt to create
#    file locks within the instance directory that's owned by root.
#  - Basically, we need to install as root and then make sure the thing gets
#    owned by the service account afterwards.
#  - Ultimately, this is what IBM documents - a series of 'chown' on various
#    directories.
#
# We might be able to be more specific about ownership later on.
#
# References:
#   - http://www-01.ibm.com/support/knowledgecenter/SSAW57_6.1.0/com.ibm.websphere.nd.multiplatform.doc/info/ae/ae/tpro_nonrootpro.html?cp=SSAW57_6.1.0%2F3-4-0-10-4-1
#   - http://www-10.lotus.com/ldd/portalwiki.nsf/dx/Installing_and_Configuring_WebSphere_Portal_v8_as_a_non-root_user
#   - http://publib.boulder.ibm.com/infocenter/wsdoc400/v6r0/index.jsp?topic=/com.ibm.websphere.iseries.doc/info/ae/ae/tsec_isprfchg.html
#   - ftp://ftp.software.ibm.com/software/iea/content/com.ibm.iea.infosphere_is/infosphere_is/8.5/configuration/ConfigWebSphere.pdf
#
define websphere::ownership (
  $user,
  $group,
  $path = $title,
) {

  validate_string($user)
  validate_string($group)
  validate_absolute_path($path)

  exec { "Ownership_${title}":
    command => "chown -R ${user}:${group} ${path}",
    unless  => "find ${path} ! -type l \\( ! -user ${user} -type f \\) -o \\( ! -group ${group} \\) -a \\( -type f \\)| wc -l | awk '{print \$1}' | grep -qE '^0'",
    path    => [ '/bin', '/usr/bin' ],
  }
}
