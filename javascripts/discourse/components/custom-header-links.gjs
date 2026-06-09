import { tracked } from "@glimmer/tracking";
import Component from "@ember/component";
import { hash } from "@ember/helper";
import { action } from "@ember/object";
import { service } from "@ember/service";
import DButton from "discourse/components/d-button";
import concatClass from "discourse/helpers/concat-class";
import closeOnClickOutside from "discourse/modifiers/close-on-click-outside";
import { i18n } from "discourse-i18n";
import CustomHeaderLink from "./custom-header-link";

export default class CustomHeaderLinks extends Component {
  @service siteSettings;
  @service site;

  @tracked showLinks = !this.site.mobileView;

  @action
  toggleHeaderLinks() {
    this.showLinks = !this.showLinks;

    if (this.showLinks) {
      document.body.classList.add("dropdown-header-open");
    } else {
      document.body.classList.remove("dropdown-header-open");
    }
  }

  get headerLinks() {
    return JSON.parse(settings.header_links);
  }

  // In "split" mode the links are divided into two groups so they can sit
  // either side of the centred site logo. Every other mode (and mobile, which
  // keeps the single dropdown menu) renders one group.
  get linkGroups() {
    const links = this.headerLinks;

    if (settings.links_position !== "split" || this.site.mobileView) {
      return [links];
    }

    // Odd counts put the extra link in the right-hand group, matching the
    // common layout where trailing items (Shop, Sign in, ...) sit on the right.
    const midpoint = Math.floor(links.length / 2);
    return [links.slice(0, midpoint), links.slice(midpoint)];
  }

  <template>
    <nav
      class={{concatClass
        "custom-header-links"
        (if @outletArgs.minimized "scrolling")
      }}
    >
      {{#if this.site.mobileView}}
        <span class="btn-custom-header-dropdown-mobile">
          <DButton
            @icon="square-caret-down"
            @title={{i18n "custom_header.discord"}}
            @action={{this.toggleHeaderLinks}}
          />
        </span>
      {{/if}}

      {{#if this.showLinks}}
        {{#each this.linkGroups as |group|}}
          <ul
            class="top-level-links"
            {{(if
              this.site.mobileView
              (modifier
                closeOnClickOutside
                this.toggleHeaderLinks
                (hash target=this.element)
              )
            )}}
          >
            {{#each group as |item|}}
              <CustomHeaderLink
                @item={{item}}
                @toggleHeaderLinks={{this.toggleHeaderLinks}}
              />
            {{/each}}
          </ul>
        {{/each}}
      {{/if}}
    </nav>
  </template>
}
