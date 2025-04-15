#include "my_application.h"
#include <bitsdojo_window_linux/bitsdojo_window_plugin.h>

#include <flutter_linux/flutter_linux.h>
#include <flutter_linux/fl_method_channel.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif
#include <cstring>
#include <gtk/gtk.h>

#include "flutter/generated_plugin_registrant.h"

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)

// Correct forward declaration for the method call handler using FlMethodResponseHandle
static void window_control_method_call(
  FlMethodChannel* channel,
  FlMethodCall* method_call,
  FlMethodResponseHandle* response_handle, // Use FlMethodResponseHandle*
  gpointer user_data);

// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

  // Ensure the window is resizable
  gtk_window_set_resizable(window, TRUE);

  // Use a header bar when running in GNOME as this is the common style used
  // by applications and is the setup most users will be using (e.g. Ubuntu
  // desktop).
  // If running on X and not using GNOME then just use a traditional title bar
  // in case the window manager does more exotic layout, e.g. tiling.
  // If running on Wayland assume the header bar will work (may need changing
  // if future cases occur).
  gboolean use_header_bar = TRUE;
#ifdef GDK_WINDOWING_X11
  GdkScreen* screen = gtk_window_get_screen(window);
  if (GDK_IS_X11_SCREEN(screen)) {
    const gchar* wm_name = gdk_x11_screen_get_window_manager_name(screen);
    if (g_strcmp0(wm_name, "GNOME Shell") != 0) {
      use_header_bar = FALSE;
    }
  }
#endif
  if (use_header_bar) {
    // REMOVE the GTK header bar for a true frameless window
    // GtkHeaderBar* header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
    // gtk_widget_show(GTK_WIDGET(header_bar));
    // gtk_header_bar_set_title(header_bar, "codeforge");
    // gtk_header_bar_set_show_close_button(header_bar, TRUE);
    // gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));
  } else {
    // REMOVE the fallback title as well
    // gtk_window_set_title(window, "codeforge");
  }

  auto bdw = bitsdojo_window_from(window);            // <--- add this line
  bdw->setCustomFrame(true);                          // <-- add this line
  //gtk_window_set_default_size(window, 1280, 720);   // <-- comment this line
  gtk_widget_show(GTK_WIDGET(window));

  //bitsdojo_window 

  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);

  // Get messenger
  g_autoptr(FlBinaryMessenger) messenger = fl_engine_get_binary_messenger(fl_view_get_engine(view));
  // Create codec
  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  // Create channel
  g_autoptr(FlMethodChannel) channel = fl_method_channel_new(messenger,
                                                           "window_control_channel",
                                                           FL_METHOD_CODEC(codec));
  // Set the handler with the correct signature
  fl_method_channel_set_method_call_handler(channel,
                                          window_control_method_call,
                                          window, // user_data
                                          nullptr); // destroy_notify

  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

// Correct implementation of the method call handler using FlMethodResponseHandle
static void window_control_method_call(
  FlMethodChannel* channel,
  FlMethodCall* method_call,
  FlMethodResponseHandle* response_handle, // Use FlMethodResponseHandle*
  gpointer user_data) {
  GtkWindow* window = GTK_WINDOW(user_data);
  const gchar* method = fl_method_call_get_name(method_call);

  if (strcmp(method, "maximize") == 0) {
    gtk_window_maximize(window);
    // Use fl_method_channel_respond_success with response_handle
    fl_method_channel_respond_success(channel, response_handle, nullptr, nullptr);
  } else if (strcmp(method, "unmaximize") == 0) {
    gtk_window_unmaximize(window);
    // Use fl_method_channel_respond_success with response_handle
    fl_method_channel_respond_success(channel, response_handle, nullptr, nullptr);
  } else if (strcmp(method, "isMaximized") == 0) {
    gboolean maximized = gtk_window_is_maximized(window);
    g_autoptr(FlValue) result = fl_value_new_bool(maximized);
    // Use fl_method_channel_respond_success with response_handle
    fl_method_channel_respond_success(channel, response_handle, result, nullptr);
  } else {
    // Use fl_method_channel_respond_not_implemented with response_handle
    fl_method_channel_respond_not_implemented(channel, response_handle, nullptr);
  }
}

// Implements GApplication::local_command_line.
static gboolean my_application_local_command_line(GApplication* application, gchar*** arguments, int* exit_status) {
  MyApplication* self = MY_APPLICATION(application);
  // Strip out the first argument as it is the binary name.
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error)) {
     g_warning("Failed to register: %s", error->message);
     *exit_status = 1;
     return TRUE;
  }

  g_application_activate(application);
  *exit_status = 0;

  return TRUE;
}

// Implements GApplication::startup.
static void my_application_startup(GApplication* application) {
  //MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application startup.

  G_APPLICATION_CLASS(my_application_parent_class)->startup(application);
}

// Implements GApplication::shutdown.
static void my_application_shutdown(GApplication* application) {
  //MyApplication* self = MY_APPLICATION(object);

  // Perform any actions required at application shutdown.

  G_APPLICATION_CLASS(my_application_parent_class)->shutdown(application);
}

// Implements GObject::dispose.
static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line = my_application_local_command_line;
  G_APPLICATION_CLASS(klass)->startup = my_application_startup;
  G_APPLICATION_CLASS(klass)->shutdown = my_application_shutdown;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {}

MyApplication* my_application_new() {
  // Set the program name to the application ID, which helps various systems
  // like GTK and desktop environments map this running application to its
  // corresponding .desktop file. This ensures better integration by allowing
  // the application to be recognized beyond its binary name.
  g_set_prgname(APPLICATION_ID);

  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID,
                                     "flags", G_APPLICATION_NON_UNIQUE,
                                     nullptr));
}
