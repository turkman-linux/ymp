#pragma once
#include <glib-object.h>

G_BEGIN_DECLS

#define YMP_TYPE_OBJECT (ymp_object_get_type())

G_DECLARE_DERIVABLE_TYPE(YmpObject, ymp_object, YMP, OBJECT, GObject)

struct _YmpObjectClass {
    GObjectClass parent_class;

};

YmpObject *ymp_object_new(void);

G_END_DECLS

G_DEFINE_TYPE(YmpObject, ymp_object, G_TYPE_OBJECT)

static void ymp_object_class_init(YmpObjectClass *klass) {
    /* Class initialization goes here */
}

static void ymp_object_init(YmpObject *self) {
    /* Instance initialization goes here */
}


YmpObject *ymp_object_new(void) {
    return g_object_new(YMP_TYPE_OBJECT, NULL);
}
