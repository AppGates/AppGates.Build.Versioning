using System;
using AppGates.Build.Versioning.Test.TransitiveProjectLibrary;

namespace AppGates.Build.Versioning.Test.ReferencingLibrary
{
    public class Class123
    {
        public void Dummy()
        {
            _ = new TransitiveClass();
        }

       
    }
}
