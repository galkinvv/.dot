/// <summary>
/// Helper to expose private object fields for debugging purposes
/// </summary>
/// <example>
///  var dyn = Exposed.Fields.From(object_with_private_fields);
///  Console.WriteLine((string)d.name + (string)d.inner.name);
/// </example>
namespace Exposed
{
   using System.Reflection;
   using System.Dynamic;
   using System.Linq.Expressions;

   public sealed class Fields : DynamicObject
   {
      private static readonly System.Type selfType = typeof(Fields);
      private static readonly MethodInfo getMethod = selfType.GetMethod("Get");
      private static readonly MethodInfo unWrapMethod = selfType.GetMethod("UnWrap");

      private sealed class FieldsMetaObject : DynamicMetaObject
      {
         public FieldsMetaObject(Expression expression, Fields value) :
             base(expression, BindingRestrictions.Empty, value)
         { }

         public override DynamicMetaObject BindConvert(ConvertBinder binder) =>
             new DynamicMetaObject(
               Expression.Call(unWrapMethod.MakeGenericMethod(binder.ReturnType), Expression),
               BindingRestrictions.GetTypeRestriction(Expression, selfType));

         public override DynamicMetaObject BindGetMember(GetMemberBinder binder) =>
            new DynamicMetaObject(
               Expression.Call(Expression.Convert(Expression, selfType), getMethod, Expression.Constant(binder.Name)),
               BindingRestrictions.GetTypeRestriction(Expression, selfType));
      }

      private object _wrapped;

      private Fields(object wrapped) => _wrapped = wrapped;

      public static dynamic From(object wrapped) => wrapped == null ? null : new Fields(wrapped);

      public dynamic Get(string fieldName) =>
         From(_wrapped.GetType().GetField(fieldName, BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic).GetValue(_wrapped));

      public static T UnWrap<T>(object self) => (T)((Fields)self)._wrapped;

      public override DynamicMetaObject GetMetaObject(Expression expression) => new FieldsMetaObject(expression, this);
   }
}
