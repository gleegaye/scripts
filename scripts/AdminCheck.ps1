using System.Security.Principal;
bool IsAnAdministrator ()
{
WindowsIdentity identity = WindowsIdentity.GetCurrent();
WindowsPrincipal principal = new WindowsPrincipal (identity);
return principal.IsInRole(WindowsBuiltInRole.Administrator);
}